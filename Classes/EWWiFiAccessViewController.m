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


#define HTTP_STATUS_OK 200
#define HTTP_STATUS_NOT_MODIFIED 304
#define HTTP_STATUS_NOT_FOUND 404


static NSString *kEWLastImportKey = @"EWLastImportDate";
static NSString *kEWLastExportKey = @"EWLastExportDate";


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
@synthesize progressDetailView;
@synthesize progressView;
@synthesize lastImportLabel;
@synthesize lastExportLabel;


- (id)init {
    if (self = [super initWithNibName:@"EWWiFiAccessView" bundle:nil]) {
		self.title = @"Wi-Fi Import/Export";
		self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}


- (void)dealloc {
	[database release];
	[activeDetailView release];
	[activityView release];
	[detailView release];
	[exportDefaults release];
	[inactiveDetailView release];
	[lastExportLabel release];
	[lastImportLabel release];
	[progressDetailView release];
	[progressView release];
	[reachability release];
	[statusLabel release];
	[webResources release];
	[webServer release];
	[importer release];
    [super dealloc];
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

	[df release];
}


- (void)setCurrentDateForKey:(NSString *)key {
	NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];
	[uds setObject:[NSDate date] forKey:key];
	[self updateLastImportExportLabels];
}


- (void)viewWillAppear:(BOOL)animated {
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
	[RootViewController setAutorotationEnabled:NO];
	[self updateLastImportExportLabels];
	[reachability startMonitoring];
}


- (void)viewWillDisappear:(BOOL)animated {
	[reachability stopMonitoring];
	[webServer stop];
	statusLabel.text = @"Off";
	[self displayDetailView:nil];
	[RootViewController setAutorotationEnabled:YES];
}


- (void)viewDidUnload {
	[reachability release];
	reachability = nil;
	[webServer release];
	webServer = nil;
	self.statusLabel = nil;
	self.activityView = nil;
	self.detailView = nil;
	self.inactiveDetailView = nil;
	self.activeDetailView = nil;
	self.progressDetailView = nil;
	self.progressView = nil;
	self.lastImportLabel = nil;
	self.lastExportLabel = nil;
}


#pragma mark Detail View Swapping


- (void)displayDetailView:(UIView *)view {
	view.alpha = 0;
	[UIView beginAnimations:@"DetailTransition" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(detailViewTransitionDidStop:finished:context:)];
	for (UIView *otherView in [detailView subviews]) {
		otherView.alpha = 0;
	}
	[detailView addSubview:view];
	view.alpha = 1;
	[UIView commitAnimations];
}


- (void)detailViewTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	NSArray *viewArray = [[detailView subviews] copy];
	for (UIView *view in viewArray) {
		if (view.alpha == 0) [view removeFromSuperview];
	}
	[viewArray release];
}


- (void)prepareProgressDetailView {
	UILabel *titleLabel = (id)[progressDetailView viewWithTag:kEWProgressTitleTag];
	titleLabel.text = @"Importing";
	[[progressDetailView viewWithTag:kEWProgressDetailTag] setHidden:YES];
	[[progressDetailView viewWithTag:kEWProgressButtonTag] setHidden:YES];
}


#pragma mark IBAction


- (IBAction)dismissProgressView {
	[self displayDetailView:activeDetailView];
}


#pragma mark Web Server Stuff


- (void)sendNotFoundErrorToConnection:(MicroWebConnection *)connection {
	[connection beginResponseWithStatus:HTTP_STATUS_NOT_FOUND];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection endResponseWithBodyString:@"Resource Not Found"];
}


- (void)sendFileAtPath:(NSString *)path contentType:(NSString *)contentType toConnection:(MicroWebConnection *)connection {

	if (path == nil) {
		[self sendNotFoundErrorToConnection:connection];
		return;
	}
	
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	NSDate *lastModifiedDate = [attrs fileModificationDate];

	NSDate *ifModifiedSinceDate = [connection dateForRequestHeader:@"If-Modified-Since"];
	if (ifModifiedSinceDate &&
		[ifModifiedSinceDate compare:lastModifiedDate] != NSOrderedAscending) {
		[connection beginResponseWithStatus:HTTP_STATUS_NOT_MODIFIED];
		[connection endResponseWithBodyData:[NSData data]];
		return;
	}
	
	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:contentType forResponseHeader:@"Content-Type"];
	[connection setValue:lastModifiedDate forResponseHeader:@"Last-Modified"];
	
	if ([path hasSuffix:@".gz"]) {
		[connection setValue:@"gzip" forResponseHeader:@"Content-Encoding"];
	}
	
	NSData *contentData;
	
	if ([contentType isEqualToString:@"image/png"]) {
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
		contentData = [UIImagePNGRepresentation(image) retain];
		[image release];
	} else {
		contentData = [[NSData alloc] initWithContentsOfFile:path];
	}
	
	[connection endResponseWithBodyData:contentData];
	[contentData release];
}


- (void)sendHTMLResourceNamed:(NSString *)name toConnection:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"html.gz"];
	[self sendFileAtPath:path 
			 contentType:@"text/html; charset=utf-8"
			toConnection:connection];
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
	[df autorelease];
	return [NSDictionary dictionaryWithObjectsAndKeys:
			format, @"value",
			label, @"label",
			nil];
}


- (void)sendValuesJavaScriptToConnection:(MicroWebConnection *)connection {
	UIDevice *device = [UIDevice currentDevice];
	NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
	NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
	NSString *copyright = [info objectForKey:@"NSHumanReadableCopyright"];
	
	NSMutableDictionary *root = [[NSMutableDictionary alloc] init];

	[root setObject:[device name] forKey:@"deviceName"];
	[root setObject:[device localizedModel] forKey:@"deviceModel"];
	[root setObject:version forKey:@"version"];
	[root setObject:copyright forKey:@"copyright"];
	
	// Formats
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	[array addObject:DateFormatDictionary(@"y-MM-dd", @"ISO")];
	[array addObject:DateFormatDictionary(nil, @"Local")];
	[root setObject:[[array copy] autorelease] forKey:@"dateFormats"];
	[array removeAllObjects];

	for (id weightUnit in [NSUserDefaults weightUnitsForExport]) {
		[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						  weightUnit, @"value",
						  [NSUserDefaults nameForWeightUnit:weightUnit], @"label",
						  nil]];
	}
	[root setObject:[[array copy] autorelease] forKey:@"weightFormats"];
	[array removeAllObjects];
	
	int i = 0;
	for (NSString *name in EWFatFormatterNames()) {
		[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
						  [NSString stringWithFormat:@"%d", i++], @"value",
						  name, @"label",
						  nil]];
	}
	[root setObject:array forKey:@"fatFormats"];
	[array release];
	
	// Export Defaults
	if (exportDefaults == nil) {
		exportDefaults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"ExportDefaults"] mutableCopy];
		NSAssert(exportDefaults, @"Can't find ExportDefaults in defaults db");
	}
	
	[root setObject:exportDefaults forKey:@"exportDefaults"];

	NSMutableData *json = [[NSMutableData alloc] init];
	[json appendBytes:"var FatWatch=" length:13];
	[root appendJSONRepresentationToData:json];
	[json appendBytes:";" length:1];
	
	[root release];
	
	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/javascript; charset=utf-8" forResponseHeader:@"Content-Type"];
	[connection setValue:@"no-cache" forResponseHeader:@"Cache-Control"];
	[connection endResponseWithBodyData:json];

	[json release];
}


- (void)sendFlagImage:(MicroWebConnection *)connection {
	int flagIndex = [[[connection requestURL] query] intValue];
	NSString *name = [EWFlagButton iconNameForFlagIndex:flagIndex];
	NSString *path = [[NSBundle mainBundle] pathForResource:name
													 ofType:@"png"
												inDirectory:@"FlagIcons"];
	[self sendFileAtPath:path contentType:@"image/png" toConnection:connection];
}


- (void)handleExport:(MicroWebConnection *)connection {
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Export Parameters: %@", form);
#endif
	
	NSArray *fieldArray = [NSArray arrayWithObjects:
						   @"date",@"weight",@"trendWeight",@"fat",
						   @"flag0",@"flag1",@"flag2",@"flag3",@"note",nil];

	NSArray *allExportKeys = [[exportDefaults allKeys] copy];
	for (NSString *exportKey in allExportKeys) {
		// exportFooBar => fooBar
		NSString *key = [exportKey stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:[[exportKey substringWithRange:NSMakeRange(6,1)] lowercaseString]];
		if ([form hasKey:key]) {
			[exportDefaults setObject:[form stringForKey:key] forKey:exportKey];
		}
		else if (![key hasSuffix:@"Name"] && ![key hasSuffix:@"Format"]) {
			[exportDefaults setObject:(id)kCFBooleanFalse forKey:exportKey];
		}
	}
	[allExportKeys release];
	
	[[NSUserDefaults standardUserDefaults] setObject:exportDefaults forKey:@"ExportDefaults"];
	
	NSMutableDictionary *formatterDictionary = [NSMutableDictionary dictionary];
	
	NSFormatter *df = [EWDateFormatter formatterWithDateFormat:[form stringForKey:@"dateFormat"]];
	[formatterDictionary setObject:df forKey:@"date"];
	
	EWWeightUnit weightUnit = [[form stringForKey:@"weightFormat"] intValue];
	NSFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport unit:weightUnit];
	[formatterDictionary setObject:wf forKey:@"weight"];
	[formatterDictionary setObject:wf forKey:@"trendWeight"];
	
	NSFormatter *ff = EWFatFormatterAtIndex([[form stringForKey:@"fatFormat"] intValue]);
	[formatterDictionary setObject:ff forKey:@"fat"];
		
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
					 formatter:[formatterDictionary objectForKey:key]];
		}
	}
	
	[form release];
	
	NSData *data = [exporter dataExportedFromDatabase:database];
	
	if (data) {
		[self setCurrentDateForKey:kEWLastExportKey];

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
		
		[isoDF release];
		
		[connection setValue:[exporter contentType] forResponseHeader:@"Content-Type"];
		[connection setValue:contentDisposition forResponseHeader:@"Content-Disposition"];
#endif
		
		[connection endResponseWithBodyData:data];
	} else {
		[connection respondWithErrorMessage:@"Unable to export data."];
	}

	[exporter release];
}


- (void)receiveUpload:(MicroWebConnection *)connection {
	if (importer) {
		if (importer.importing) {
			[self sendHTMLResourceNamed:@"importPending" toConnection:connection];
			return;
		} else {
			[importer release];
			importer = nil;
		}
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	NSData *data = [form dataForKey:@"filedata"];
	NSStringEncoding encoding = [[form stringForKey:@"encoding"] intValue];
	[form release];
	
	if (data == nil) {
		[self sendHTMLResourceNamed:@"importNoData" toConnection:connection];
		return;
	}

	importer = [[EWImporter alloc] initWithData:data encoding:encoding];
	importer.delegate = self;
		
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
	
	[json release];
}


- (void)processImport:(MicroWebConnection *)connection {
	if (importer == nil) {
		[connection respondWithErrorMessage:@"No Import to Process!"];
		return;
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
	if (! [form hasKey:@"doImport"]) {
		[form release];
		[importer release];
		importer = nil;
		[connection respondWithRedirectToPath:@"/#import"];
		return;
	}
	
	[importer setColumn:[[form stringForKey:@"date"] intValue] 
			   forField:EWImporterFieldDate];
	[importer setColumn:[[form stringForKey:@"weight"] intValue] 
			   forField:EWImporterFieldWeight];
	[importer setColumn:[[form stringForKey:@"fat"] intValue] 
			   forField:EWImporterFieldFatRatio];
	[importer setColumn:[[form stringForKey:@"flag0"] intValue] 
			   forField:EWImporterFieldFlag0];
	[importer setColumn:[[form stringForKey:@"flag1"] intValue] 
			   forField:EWImporterFieldFlag1];
	[importer setColumn:[[form stringForKey:@"flag2"] intValue] 
			   forField:EWImporterFieldFlag2];
	[importer setColumn:[[form stringForKey:@"flag3"] intValue] 
			   forField:EWImporterFieldFlag3];
	[importer setColumn:[[form stringForKey:@"note"] intValue] 
			   forField:EWImporterFieldNote];
	
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
	
	[form release];
	
	if ([importer performImportToDatabase:database]) {
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		[self prepareProgressDetailView];
		[self displayDetailView:progressDetailView];
		[self sendHTMLResourceNamed:@"importAccepted" toConnection:connection];
	} else {
		[connection respondWithErrorMessage:@"Importer Problem!"];
	}
}


#pragma mark EWImporterDelegate


- (void)importer:(EWImporter *)anImporter importProgress:(float)progress {
	progressView.progress = progress;
}


- (void)importer:(EWImporter *)anImporter didImportNumberOfMeasurements:(int)importedCount outOfNumberOfRows:(int)rowCount {
	
	[importer autorelease];
	importer = nil;

	[self setCurrentDateForKey:kEWLastImportKey];
	
	NSString *msg;

	// \xc2\xa0 : NO-BREAK SPACE
	if (importedCount > 0) {
		msg = [NSString stringWithFormat:NSLocalizedString(@"Imported %d\xc2\xa0measurements;\n%d\xc2\xa0lines ignored.", @"After import, count of lines read and ignored."), 
			   importedCount,
			   rowCount - importedCount];
	} else {
		msg = [NSString stringWithFormat:NSLocalizedString(@"Read %d\xc2\xa0rows but no measurements were found. The file may not be in the correct format.", @"After import, count of lines read, nothing imported."),
			   rowCount];
	}

	progressView.progress = 1.0f;

	UILabel *titleLabel = (id)[progressDetailView viewWithTag:kEWProgressTitleTag];
	titleLabel.text = @"Done";

	UILabel *detailLabel = (id)[progressDetailView viewWithTag:kEWProgressDetailTag];
	detailLabel.text = msg;
	detailLabel.hidden = NO;

	[[progressDetailView viewWithTag:kEWProgressButtonTag] setHidden:NO];

	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
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
	NSString *path = [[connection requestURL] path];
	
	if (webResources == nil) {
		NSString *p = [[NSBundle mainBundle] pathForResource:@"WebResources" ofType:@"plist"];
		webResources = [[NSDictionary alloc] initWithContentsOfFile:p];
	}
	
	NSDictionary *rsrc = [webResources objectForKey:path];
	if (rsrc) {
		NSString *action = [rsrc objectForKey:@"Action"];
		if (action) {
			[self performSelector:NSSelectorFromString(action) 
					   withObject:connection];
		} else {
			NSString *path = [[NSBundle mainBundle] pathForResource:[rsrc objectForKey:@"Name"]
															 ofType:[rsrc objectForKey:@"Type"]];
			[self sendFileAtPath:path 
					 contentType:[rsrc objectForKey:@"Content-Type"]
					toConnection:connection];
		}
	} else {
		[self sendNotFoundErrorToConnection:connection];
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
