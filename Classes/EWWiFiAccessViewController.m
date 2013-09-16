//
//  EWWiFiAccessViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRJSON.h"
#import "BRReachability.h"
#import "CSVExporter.h"
#import "EWExporter.h"
#import "EWImporter.h"
#import "EWWiFiAccessViewController.h"
#import "FormDataParser.h"
#import "MicroWebServer.h"
#import "RootViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWWeightFormatter.h"
#import "EWFlagButton.h"
#import "EWDateFormatter.h"
#import "ImportViewController.h"
#import "EWDatabase.h"


#define HTTP_STATUS_OK 200
#define HTTP_STATUS_NOT_MODIFIED 304
#define HTTP_STATUS_NOT_FOUND 404


@interface MicroWebConnection (EWAdditions)
- (void)sendNotFoundError;
- (void)sendFileAtPath:(NSString *)path contentType:(NSString *)contentType;
- (void)sendHTMLResourceNamed:(NSString *)name;
@end


@interface EWWiFiAccessViewController ()
- (void)displayDetailView:(UIView *)detailView;
@end



@implementation EWWiFiAccessViewController


@synthesize database;
@synthesize statusLabel;
@synthesize activityView;
@synthesize detailView;
@synthesize inactiveDetailView;
@synthesize activeDetailView;
@synthesize lastImportLabel;
@synthesize lastExportLabel;


- (id)init {
    if ((self = [super initWithNibName:@"EWWiFiAccessView" bundle:nil])) {
		self.title = @"Wi-Fi Import/Export";
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}




- (void)updateLastImportExportLabels {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterShortStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
	NSDate *date;
	
	// If not set, leave default text that was stored in the nib.
	
	date = [uds objectForKey:kEWLastImportKey];
	if (date) lastImportLabel.text = [df stringFromDate:date];
	
	date = [uds objectForKey:kEWLastExportKey];
	if (date) lastExportLabel.text = [df stringFromDate:date];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	if (webServer == nil) {
		webServer = [[MicroWebServer alloc] init];
		NSString *devName = [[UIDevice currentDevice] name];
		webServer.name = [NSString stringWithFormat:@"FatWatch (%@)", devName];
		webServer.delegate = self;
	}
	if (reachability == nil) {
		reachability = [[BRReachability alloc] init];
		reachability.delegate = self;
	}
}	
	
	
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLastImportExportLabels];
    // If `importer` is nil, the view is being displayed for the first time, so
    // we set up shop. Otherwise, we an ImportViewController has just been
    // dismissed, and there is nothing to do but clean up.
    if (importer == nil) {
        [reachability startMonitoring];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else {
        importer = nil;
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // If `importer` is nil, the view is being popped off the navigation stack
    // and it's time to clean up. Otherwise, an ImportViewController has just
    // been pushed on top of it and there is nothing we need to do.
    if (importer == nil) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [reachability stopMonitoring];
        [webServer stop];
        statusLabel.text = @"Off";
        [self displayDetailView:nil];
    }
}


- (void)viewDidUnload {
	reachability = nil;
	webServer = nil;
	self.statusLabel = nil;
	self.activityView = nil;
	self.detailView = nil;
	self.inactiveDetailView = nil;
	self.activeDetailView = nil;
	self.lastImportLabel = nil;
	self.lastExportLabel = nil;
}


#pragma mark Detail View Swapping


- (void)displayDetailView:(UIView *)view {
	view.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^(void) {
        for (UIView *otherView in [detailView subviews]) {
            otherView.alpha = 0;
        }
        [detailView addSubview:view];
        view.alpha = 1;
    } completion:^(BOOL finished) {
        NSArray *viewArray = [[detailView subviews] copy];
        for (UIView *subview in viewArray) {
            if (subview.alpha == 0) [subview removeFromSuperview];
        }
    }];
}


#pragma mark Web Server Actions


NSDictionary *DateFormatDictionary(NSString *format, NSString *name) {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	if (format) {
		[df setDateFormat:format];
	} else {
		[df setDateStyle:NSDateFormatterShortStyle];
		[df setTimeStyle:NSDateFormatterNoStyle];
		format = [df dateFormat];
	}
	NSString *label = [NSString stringWithFormat:@"%@ (%@)",
					   [df stringFromDate:[NSDate date]],
					   name];
	return @{@"value": format, @"label": label};
}


- (void)sendValuesJavaScriptToConnection:(MicroWebConnection *)connection {
	UIDevice *device = [UIDevice currentDevice];
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *version = info[@"CFBundleShortVersionString"];
	NSString *copyright = info[@"NSHumanReadableCopyright"];
	
	NSMutableDictionary *root = [[NSMutableDictionary alloc] init];

	root[@"deviceName"] = [device name];
	root[@"deviceModel"] = [device localizedModel];
	root[@"version"] = version;
	root[@"copyright"] = copyright;
	
	// Formats
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	[array addObject:DateFormatDictionary(@"y-MM-dd", @"ISO")];
	[array addObject:DateFormatDictionary(nil, @"Local")];
	root[@"dateFormats"] = [array copy];
	[array removeAllObjects];

	for (id weightUnit in [NSUserDefaults weightUnitsForExport]) {
		[array addObject:@{@"value": weightUnit,
						  @"label": [NSUserDefaults nameForWeightUnit:weightUnit]}];
	}
	root[@"weightFormats"] = [array copy];
	[array removeAllObjects];
	
	int i = 0;
	for (NSString *name in EWFatFormatterNames()) {
		[array addObject:@{@"value": [NSString stringWithFormat:@"%d", i++],
						  @"label": name}];
	}
	root[@"fatFormats"] = array;
	
	// Export Defaults
	if (exportDefaults == nil) {
		exportDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ExportDefaults"] mutableCopy];
		NSAssert(exportDefaults, @"Can't find ExportDefaults in defaults db");
	}
	
	root[@"exportDefaults"] = exportDefaults;

	NSMutableData *json = [[NSMutableData alloc] init];
	[json appendBytes:"var FatWatch=" length:13];
	[root appendJSONRepresentationToData:json];
	[json appendBytes:";" length:1];
	
	
	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/javascript; charset=utf-8" forResponseHeader:@"Content-Type"];
	[connection setValue:@"no-cache" forResponseHeader:@"Cache-Control"];
	[connection endResponseWithBodyData:json];

}


- (void)sendFlagImage:(MicroWebConnection *)connection {
	int flagIndex = [[[connection requestURL] query] intValue];
	NSString *name = [EWFlagButton iconNameForFlagIndex:flagIndex];
	NSString *path = [[NSBundle mainBundle] pathForResource:name
													 ofType:@"png"
												inDirectory:@"FlagIcons"];
	[connection sendFileAtPath:path contentType:@"image/png"];
}


- (void)handleExport:(MicroWebConnection *)connection {
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Export Parameters: %@", form);
#endif
	
	NSArray *fieldArray = @[@"date",@"weight",@"trendWeight",@"fat",
						   @"flag0",@"flag1",@"flag2",@"flag3",@"note"];

	NSArray *allExportKeys = [[exportDefaults allKeys] copy];
	for (NSString *exportKey in allExportKeys) {
		// exportFooBar => fooBar
		NSString *key = [exportKey stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:[[exportKey substringWithRange:NSMakeRange(6,1)] lowercaseString]];
		if ([form hasKey:key]) {
			exportDefaults[exportKey] = [form stringForKey:key];
		}
		else if (![key hasSuffix:@"Name"] && ![key hasSuffix:@"Format"]) {
			exportDefaults[exportKey] = (id)kCFBooleanFalse;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:exportDefaults forKey:@"ExportDefaults"];
	
	NSMutableDictionary *formatterDictionary = [NSMutableDictionary dictionary];
	
	NSFormatter *df = [EWDateFormatter formatterWithDateFormat:[form stringForKey:@"dateFormat"]];
	formatterDictionary[@"date"] = df;
	
	EWWeightUnit weightUnit = [[form stringForKey:@"weightFormat"] intValue];
	NSFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport unit:weightUnit];
	formatterDictionary[@"weight"] = wf;
	formatterDictionary[@"trendWeight"] = wf;
	
	NSFormatter *ff = EWFatFormatterAtIndex([[form stringForKey:@"fatFormat"] intValue]);
	formatterDictionary[@"fat"] = ff;
		
	NSArray *order;
	
	NSString *orderString = [form stringForKey:@"order"];
	if ([orderString length] > 0) {
		order = [orderString componentsSeparatedByString:@","];
	} else {
		order = fieldArray;
	}
	
	EWExporter *exporter = [[CSVExporter alloc] init];

	for (NSString *key in order) {
		if ([form hasKey:key]) {
			NSString *name = [form stringForKey:[key stringByAppendingString:@"Name"]];
			if (name == nil) name = key;
			[exporter addField:[fieldArray indexOfObject:key]
						  name:name
					 formatter:formatterDictionary[key]];
		}
	}
	
	
	NSData *data = [exporter dataExportedFromDatabase:database];
	
	if (data) {
        NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
        [uds setObject:[NSDate date] forKey:kEWLastExportKey];
        [self updateLastImportExportLabels];

		[connection beginResponseWithStatus:HTTP_STATUS_OK];

#if TARGET_IPHONE_SIMULATOR
		[connection setValue:@"text/plain; charset=utf-8" forResponseHeader:@"Content-Type"];
		[connection setValue:@"inline" forResponseHeader:@"Content-Disposition"];
#else
		NSDateFormatter *isoDF = [[NSDateFormatter alloc] init];
		[isoDF setDateFormat:@"y-MM-dd"];
		
		NSString *contentDisposition = 
		[NSString stringWithFormat:@"attachment; filename=\"FatWatch-Export-%@.%@\"", 
		 [isoDF stringFromDate:[NSDate date]],
		 [exporter fileExtension]];
		
		[connection setValue:[exporter contentType] forResponseHeader:@"Content-Type"];
		[connection setValue:contentDisposition forResponseHeader:@"Content-Disposition"];
#endif
		
		[connection endResponseWithBodyData:data];
	} else {
		[connection respondWithErrorMessage:@"Unable to export data."];
	}

}


- (void)receiveUpload:(MicroWebConnection *)connection {
	if (importer) {
		if (importer.importing) {
			[connection sendHTMLResourceNamed:@"importPending"];
			return;
		} else {
			importer = nil;
		}
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	NSData *data = [form dataForKey:@"filedata"];
	NSStringEncoding encoding = [[form stringForKey:@"encoding"] intValue];
	
	if (data == nil) {
		[connection sendHTMLResourceNamed:@"importNoData"];
		return;
	}

	importer = [[EWImporter alloc] initWithData:data encoding:encoding];
		
	[connection respondWithRedirectToPath:@"/import"];
}


- (void)sendImportJavaScriptToConnection:(MicroWebConnection *)connection {
	NSDictionary *root = [importer infoForJavaScript];
	
	NSMutableData *json = [[NSMutableData alloc] init];
	[json appendBytes:"var FatWatchImport=" length:19];
	[root appendJSONRepresentationToData:json];
	[json appendBytes:";" length:1];
	
	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/javascript; charset=utf-8" forResponseHeader:@"Content-Type"];
	[connection setValue:@"no-cache" forResponseHeader:@"Cache-Control"];
	[connection endResponseWithBodyData:json];
	
}


- (void)processImport:(MicroWebConnection *)connection {
	if (importer == nil) {
		[connection respondWithErrorMessage:@"No Import to Process!"];
		return;
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
	if (! [form hasKey:@"doImport"]) {
		importer = nil;
		[connection respondWithRedirectToPath:@"/#import"];
		return;
	}
	
    {
        int c;
        c = [[form stringForKey:@"date"] intValue];
        [importer setColumn:c forField:EWImporterFieldDate];
        c = [[form stringForKey:@"weight"] intValue];
        [importer setColumn:c forField:EWImporterFieldWeight];
        c = [[form stringForKey:@"fat"] intValue];
        [importer setColumn:c forField:EWImporterFieldFatRatio];
        c = [[form stringForKey:@"flag0"] intValue];
        [importer setColumn:c forField:EWImporterFieldFlag0];
        c = [[form stringForKey:@"flag1"] intValue];
        [importer setColumn:c forField:EWImporterFieldFlag1];
        c = [[form stringForKey:@"flag2"] intValue];
        [importer setColumn:c forField:EWImporterFieldFlag2];
        c = [[form stringForKey:@"flag3"] intValue];
        [importer setColumn:c forField:EWImporterFieldFlag3];
        c = [[form stringForKey:@"note"] intValue];
        [importer setColumn:c forField:EWImporterFieldNote];
    }
	
	{
		NSFormatter *df = [EWDateFormatter formatterWithDateFormat:[form stringForKey:@"dateFormat"]];
		[importer setFormatter:df forField:EWImporterFieldDate];
	}
	
	{
		EWWeightUnit weightUnit = [[form stringForKey:@"weightFormat"] intValue];
		NSFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport unit:weightUnit];
		[importer setFormatter:wf forField:EWImporterFieldWeight];
	}

	[importer setFormatter:EWFatFormatterAtIndex([[form stringForKey:@"fatFormat"] intValue]) 
				  forField:EWImporterFieldFatRatio];
	
	importer.deleteFirst = [[form stringForKey:@"prep"] isEqualToString:@"replace"];
	
    
    ImportViewController *importView = [[ImportViewController alloc] initWithImporter:importer database:database];
    [self presentViewController:importView animated:YES completion:nil];
    
    [connection sendHTMLResourceNamed:@"importAccepted"];
}


#pragma mark MicroWebServerDelegate


- (void)webConnectionWillReceiveRequest:(MicroWebConnection *)connection {
	[activityView startAnimating];
	statusLabel.text = @"Receiving";
}


- (void)webConnectionDidReceiveRequest:(MicroWebConnection *)connection {
	statusLabel.text = @"Processing";
}


- (void)webConnectionWillSendResponse:(MicroWebConnection *)connection {
	statusLabel.text = @"Sending";
}


- (void)webConnectionDidSendResponse:(MicroWebConnection *)connection {
	[activityView stopAnimating];
	statusLabel.text = @"Ready";
}


- (void)handleWebConnection:(MicroWebConnection *)connection {
	if (webResources == nil) {
		NSString *p = [[NSBundle mainBundle] pathForResource:@"WebResources" ofType:@"plist"];
		webResources = [[NSDictionary alloc] initWithContentsOfFile:p];
	}
	
	NSString *requestPath = [[connection requestURL] path];
	NSDictionary *rsrc = webResources[requestPath];
	
	if (rsrc) {
		NSString *action = rsrc[@"Action"];
		if (action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(action) withObject:connection];
#pragma clang diagnostic pop
		} else {
			NSString *path = [[NSBundle mainBundle] 
                              pathForResource:rsrc[@"Name"]
                              ofType:rsrc[@"Type"]];
            [connection sendFileAtPath:path contentType:rsrc[@"Content-Type"]];
		}
	} else {
        [connection sendNotFoundError];
	}
}


#pragma mark BRReachabilityDelegate


- (void)reachability:(BRReachability *)reachability didUpdateFlags:(SCNetworkReachabilityFlags)flags {
	BOOL networkAvailable = ((flags & kSCNetworkReachabilityFlagsReachable) &&
							 !(flags & kSCNetworkReachabilityFlagsIsWWAN));
		
	if (networkAvailable && !webServer.running) {
		// Start it up
		[webServer start];
		if (webServer.running) {
			statusLabel.text = @"Ready";
			UILabel *addressLabel = (id)[activeDetailView viewWithTag:kEWReadyAddressTag];
			UILabel *nameLabel = (id)[activeDetailView viewWithTag:kEWReadyNameTag];
			addressLabel.text = [webServer.rootURL description];
			nameLabel.text = webServer.name;
			[self displayDetailView:activeDetailView];
		} else {
			statusLabel.text = @"Failed to Start";
			[self displayDetailView:inactiveDetailView];
		}
	} else if (!networkAvailable) {
		// Shut it down
		if (webServer.running) {
			[webServer stop];
		}
		statusLabel.text = @"Off";
		[self displayDetailView:inactiveDetailView];
	}
}


@end


@implementation MicroWebConnection (EWAdditions)

- (void)sendNotFoundError
{
	[self beginResponseWithStatus:HTTP_STATUS_NOT_FOUND];
	[self setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[self endResponseWithBodyString:@"Resource Not Found"];
}

- (void)sendFileAtPath:(NSString *)path contentType:(NSString *)contentType
{
    if (path == nil) {
        [self sendNotFoundError];
        return;
    }
	
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	NSDate *lastModifiedDate = [attrs fileModificationDate];
    
	NSDate *ifModifiedSinceDate = [self dateForRequestHeader:@"If-Modified-Since"];
	if (ifModifiedSinceDate &&
		[ifModifiedSinceDate compare:lastModifiedDate] != NSOrderedAscending) {
		[self beginResponseWithStatus:HTTP_STATUS_NOT_MODIFIED];
		[self endResponseWithBodyData:[NSData data]];
		return;
	}
	
	[self beginResponseWithStatus:HTTP_STATUS_OK];
	[self setValue:contentType forResponseHeader:@"Content-Type"];
	[self setValue:lastModifiedDate forResponseHeader:@"Last-Modified"];
	
	if ([path hasSuffix:@".gz"]) {
		[self setValue:@"gzip" forResponseHeader:@"Content-Encoding"];
	}
	
	NSData *contentData;
	
	if ([contentType isEqualToString:@"image/png"]) {
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
		contentData = UIImagePNGRepresentation(image);
	} else {
		contentData = [[NSData alloc] initWithContentsOfFile:path];
	}
	
	[self endResponseWithBodyData:contentData];
}

- (void)sendHTMLResourceNamed:(NSString *)name
{
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"html.gz"];
	[self sendFileAtPath:path contentType:@"text/html; charset=utf-8"];
}

@end
