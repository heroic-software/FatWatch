//
//  EWWiFiAccessViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "BRJSON.h"
#import "BRReachability.h"
#import "CSVReader.h"
#import "CSVExporter.h"
#import "EWDBMonth.h"
#import "EWDatabase.h"
#import "EWExporter.h"
#import "EWGoal.h"
#import "EWWiFiAccessViewController.h"
#import "FormDataParser.h"
#import "MicroWebServer.h"
#import "RootViewController.h"
#import "NSUserDefaults+EWAdditions.h"
#import "EWWeightFormatter.h"


#define HTTP_STATUS_OK 200
#define HTTP_STATUS_NOT_FOUND 404


NSDateFormatter *EWDateFormatterGetISO() {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"y-MM-dd"];
	return [formatter autorelease];
}


NSDateFormatter *EWDateFormatterGetLocal() {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	return [formatter autorelease];
}


static NSString *kEWLastImportKey = @"EWLastImportDate";
static NSString *kEWLastExportKey = @"EWLastExportDate";


@implementation EWWiFiAccessViewController


@synthesize statusLabel;
@synthesize activityView;
@synthesize detailView;
@synthesize inactiveDetailView;
@synthesize activeDetailView;
@synthesize promptDetailView;
@synthesize progressDetailView;
@synthesize progressView;
@synthesize lastImportLabel;
@synthesize lastExportLabel;


- (id)init {
    if (self = [super initWithNibName:@"EWWiFiAccessView" bundle:nil]) {
		self.title = @"Wi-Fi Import/Export";
		self.hidesBottomBarWhenPushed = YES;
		
		reachability = [[BRReachability alloc] init];
		reachability.delegate = self;
		
		webServer = [[MicroWebServer alloc] init];
		NSString *devName = [[UIDevice currentDevice] name];
		webServer.name = [NSString stringWithFormat:@"FatWatch (%@)", devName];
		webServer.delegate = self;
    }
    return self;
}


- (void)dealloc {
	[activeDetailView release];
	[activityView release];
	[detailView release];
	[exportDefaults release];
	[inactiveDetailView release];
	[lastExportLabel release];
	[lastImportLabel release];
	[progressDetailView release];
	[progressView release];
	[promptDetailView release];
	[reachability release];
	[statusLabel release];
	[webResources release];
	[webServer release];
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
	
	
- (void)viewDidAppear:(BOOL)animated {
	[self updateLastImportExportLabels];
	[RootViewController setAutorotationEnabled:NO];
	[reachability startMonitoring];
}


- (void)viewWillDisappear:(BOOL)animated {
	[reachability stopMonitoring];
	[webServer stop];
	[RootViewController setAutorotationEnabled:YES];
}


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


- (void)beginImport {
	reader = [[CSVReader alloc] initWithData:importData encoding:importEncoding];
	reader.floatFormatter = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport];
	lineCount = 0;
	importCount = 0;
	
	UILabel *titleLabel = (id)[progressDetailView viewWithTag:kEWProgressTitleTag];
	titleLabel.text = @"Importing";
	progressView.progress = 0.0f;
	[[progressDetailView viewWithTag:kEWProgressDetailTag] setHidden:YES];
	[[progressDetailView viewWithTag:kEWProgressButtonTag] setHidden:YES];
	[self displayDetailView:progressDetailView];
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];

	[self performSelector:@selector(continueImport) withObject:nil afterDelay:0];
}


- (void)endImport {
	[[EWDatabase sharedDatabase] commitChanges];
	[reader release];
	reader = nil;
	[importData release];
	importData = nil;
	
	[self setCurrentDateForKey:kEWLastImportKey];
	
	NSString *msg;
	
	if (importCount > 0) {
		NSString *msgFormat = NSLocalizedString(@"Read %d lines and imported %d measurements.", @"After import, count of lines read and imported.");
		msg = [NSString stringWithFormat:msgFormat, lineCount, importCount];
	} else {
		NSString *msgFormat = NSLocalizedString(@"Read %d lines but no measurements were found. The file may not be in the correct format.", @"After import, count of lines read, nothing imported.");
		msg = [NSString stringWithFormat:msgFormat, lineCount];
	}

	UILabel *titleLabel = (id)[progressDetailView viewWithTag:kEWProgressTitleTag];
	titleLabel.text = @"Done";
	
	progressView.progress = 1.0f;
	
	UILabel *detailLabel = (id)[progressDetailView viewWithTag:kEWProgressDetailTag];
	detailLabel.text = msg;
	detailLabel.hidden = NO;
	
	[[progressDetailView viewWithTag:kEWProgressButtonTag] setHidden:NO];
	
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)continueImport {
	const EWDatabase *db = [EWDatabase sharedDatabase];
	NSDate *recessDate = [NSDate dateWithTimeIntervalSinceNow:0.2];
	NSDateFormatter *isoDateFormatter = EWDateFormatterGetISO();
	NSDateFormatter *localDateFormatter = EWDateFormatterGetLocal();
	
	while ([reader nextRow]) {
		lineCount += 1;
		NSString *dateString = [reader readString];
		if (dateString != nil) {
			NSDate *date = [isoDateFormatter dateFromString:dateString];
			if (date == nil) {
				date = [localDateFormatter dateFromString:dateString];
			}
			if (date != nil) {
				float scaleWeight = [reader readFloat];
				BOOL flag = [reader readBoolean];
				NSString *note = [reader readString];
				
				if (scaleWeight > 0 || note != nil || flag) {
					EWMonthDay monthday = EWMonthDayFromDate(date);
					EWDBMonth *md = [db getDBMonth:EWMonthDayGetMonth(monthday)];
					[md setScaleWeight:scaleWeight
							  scaleFat:0
								 flags:flag
								  note:note
								 onDay:EWMonthDayGetDay(monthday)];
					importCount += 1;
				}
			}
		}
		if ([recessDate timeIntervalSinceNow] < 0) {
			progressView.progress = reader.progress;
			[self performSelector:@selector(continueImport) 
					   withObject:nil
					   afterDelay:0];
			return;
		}
	}
		
	[self endImport];
}


#pragma mark IBAction


- (IBAction)performMergeImport {
	[self beginImport];
}


- (IBAction)performReplaceImport {
	[EWGoal deleteGoal];
	[[EWDatabase sharedDatabase] deleteAllData];
	[self beginImport];
}


- (IBAction)cancelImport {
	[importData release];
	importData = nil;
	[self displayDetailView:activeDetailView];
}


- (IBAction)dismissProgressView {
	[self displayDetailView:activeDetailView];
}


#pragma mark Web Server Stuff


- (void)sendNotFoundErrorToConnection:(MicroWebConnection *)connection {
	[connection beginResponseWithStatus:HTTP_STATUS_NOT_FOUND];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection endResponseWithBodyString:@"Resource Not Found"];
}


- (void)sendResource:(NSString *)name ofType:(NSString *)type contentType:(NSString *)contentType toConnection:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
	
	if (path == nil) {
		[self sendNotFoundErrorToConnection:connection];
		return;
	}
	
	// if (request:If-None-Match = response:ETag) send 304 Not Modified
	// if (request:If-Modified-Since = Last-Modified) send 304 Not Modified
	
	if ([contentType hasPrefix:@"text/"]) {
		contentType = [contentType stringByAppendingString:@"; charset=utf-8"];
	}

	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:contentType forResponseHeader:@"Content-Type"];
	
	if ([type hasSuffix:@".gz"]) {
		[connection setValue:@"gzip" forResponseHeader:@"Content-Encoding"];
	}
	
	NSData *contentData = [[NSData alloc] initWithContentsOfFile:path];
	[connection endResponseWithBodyData:contentData];
	[contentData release];
}


- (void)sendHTMLResourceNamed:(NSString *)name toConnection:(MicroWebConnection *)connection {
	[self sendResource:name ofType:@"html.gz"
		   contentType:@"text/html"
		  toConnection:connection];
}


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
	
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"R", @"value", @"ratio (0.0-&ndash;1.0)", @"label", nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"P", @"value", @"percent (0%&ndash;100%)", @"label", nil]];
	[root setObject:[[array copy] autorelease] forKey:@"fatFormats"];
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


- (void)handleExport:(MicroWebConnection *)connection {
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Export Parameters: %@", form);
#endif
	
	NSArray *fieldArray = [NSArray arrayWithObjects:
						   @"date",@"weight",@"trendWeight",@"fat",
						   @"flag1",@"flag2",@"flag3",@"flag4",@"note",nil];

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
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:[form stringForKey:@"dateFormat"]];
	[formatterDictionary setObject:df forKey:@"date"];
	[df release];
	
	EWWeightUnit weightUnit = [[form stringForKey:@"weightFormat"] intValue];
	NSFormatter *wf = [EWWeightFormatter weightFormatterWithStyle:EWWeightFormatterStyleExport unit:weightUnit];
	[formatterDictionary setObject:wf forKey:@"weight"];
	[formatterDictionary setObject:wf forKey:@"trendWeight"];
	
	NSNumberFormatter *ff = [[NSNumberFormatter alloc] init];
	NSString *ffName = [form stringForKey:@"fatFormat"];
	if ([ffName isEqualToString:@"R"]) {
	}
	else if ([ffName isEqualToString:@"P"]) {
		[ff setNumberStyle:NSNumberFormatterPercentStyle];
	}
	[formatterDictionary setObject:ff forKey:@"fat"];
	[ff release];
	
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
	
	NSData *data = [exporter exportedData];
	
	if (data) {
		[self setCurrentDateForKey:kEWLastExportKey];

		[connection beginResponseWithStatus:HTTP_STATUS_OK];

#if TARGET_IPHONE_SIMULATOR
		[connection setValue:@"text/plain; charset=utf-8" forResponseHeader:@"Content-Type"];
		[connection setValue:@"inline" forResponseHeader:@"Content-Disposition"];
#else
		NSDateFormatter *isoDF = EWDateFormatterGetISO();
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

	[exporter release];
}


- (void)handleImport:(MicroWebConnection *)connection {
	if (importData != nil) {
		// If we are already waiting for imported data to be handled, ignore
		// further requests.
		[self sendHTMLResourceNamed:@"importPending" 
					   toConnection:connection];
		return;
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	importData = [[form dataForKey:@"filedata"] retain];
	importEncoding = [[form stringForKey:@"encoding"] intValue];
	[form release];
	
	if (importData == nil) {
		[self sendHTMLResourceNamed:@"importNoData" 
					   toConnection:connection];
		return;
	}
	
	[self displayDetailView:promptDetailView];
		
	[self sendHTMLResourceNamed:@"importAccepted"
				   toConnection:connection];
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
		[self sendResource:[rsrc objectForKey:@"Name"]
					ofType:[rsrc objectForKey:@"Type"]
			   contentType:[rsrc objectForKey:@"Content-Type"]
			  toConnection:connection];
		return;
	}
	
	if ([path isEqualToString:@"/values.js"]) {
		[self sendValuesJavaScriptToConnection:connection];
		return;
	}
	
//	if ([path isEqualToString:@"/import.js"]) {
//		[self sendImportJavaScriptToConnection:connection];
//		return;
//	}
	
	if ([path isEqualToString:@"/export"]) {
		[self handleExport:connection];
		return;
	}
	
	if ([path isEqualToString:@"/import"]) {
		[self handleImport:connection];
		return;
	}
	
	[self sendNotFoundErrorToConnection:connection];
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
			addressLabel.text = [webServer.url description];
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
