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
#import "WeightFormatters.h"


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
	[statusLabel release];
	[activityView release];
	[detailView release];
	[inactiveDetailView release];
	[activeDetailView release];
	[promptDetailView release];
	[progressDetailView release];
	[progressView release];
	[lastImportLabel release];
	[lastExportLabel release];
	[reachability release];
	[webServer release];
	[webResources release];
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
	reader.floatFormatter = [WeightFormatters exportWeightFormatter];
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

	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"lbs", @"value", @"pounds (lbs)", @"label", nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"kgs", @"value", @"kilograms (kgs)", @"label", nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"gs", @"value", @"grams (gs)", @"label", nil]];
	[root setObject:[[array copy] autorelease] forKey:@"weightFormats"];
	[array removeAllObjects];
	
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"ratio", @"value", @"ratio (0.0-&ndash;1.0)", @"label", nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  @"percent", @"value", @"percent (0%&ndash;100%)", @"label", nil]];
	[root setObject:[[array copy] autorelease] forKey:@"fatFormats"];
	[array release];
	
	// Export Defaults
	
	NSMutableDictionary *exportDefaults = [[NSMutableDictionary alloc] init];
	
	[exportDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"exportDate"];
	[exportDefaults setObject:@"Date" forKey:@"exportDateName"];
	[exportDefaults setObject:@"y-MM-dd" forKey:@"exportDateFormat"];

	[exportDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"exportWeight"];
	[exportDefaults setObject:@"Weight" forKey:@"exportWeightName"];
	[exportDefaults setObject:@"lbs" forKey:@"exportWeightFormat"];

	[exportDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"exportTrendWeight"];
	[exportDefaults setObject:@"Trend" forKey:@"exportTrendWeightName"];
	
	[exportDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"exportFat"];
	[exportDefaults setObject:@"ratio" forKey:@"exportFatFormat"];
	[exportDefaults setObject:@"BodyFat" forKey:@"exportFatName"];
	
	[exportDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"exportFlag1"];
	[exportDefaults setObject:@"Checkmark" forKey:@"exportFlag1Name"];
	
	[exportDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"exportFlag2"];
	[exportDefaults setObject:@"Checkmark2" forKey:@"exportFlag2Name"];
	
	[exportDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"exportFlag3"];
	[exportDefaults setObject:@"Checkmark3" forKey:@"exportFlag3Name"];
	
	[exportDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"exportFlag4"];
	[exportDefaults setObject:@"Checkmark4" forKey:@"exportFlag4Name"];

	[exportDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"exportNote"];
	[exportDefaults setObject:@"Note" forKey:@"exportNoteName"];

	[root setObject:exportDefaults forKey:@"exportDefaults"];
	[exportDefaults release];

	NSMutableData *json = [[NSMutableData alloc] init];
	[json appendBytes:"var FatWatch=" length:13];
	[root appendJSONRepresentationToData:json];
	[json appendBytes:";" length:1];
	
	[root release];
	
	[connection beginResponseWithStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/javascript" forResponseHeader:@"Content-Type"];
	[connection endResponseWithBodyData:json];

	[json release];
}


- (void)handleExport:(MicroWebConnection *)connection {
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	
	NSLog(@"Export: %@", form);
	
	EWExporter *exporter = [[CSVExporter alloc] init];
	
	if ([form hasKey:@"date"]) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:[form stringForKey:@"dateFormat"]];
		[exporter addField:EWExporterFieldDate
					  name:[form stringForKey:@"dateName"]
				 formatter:df];
		[df release];
	}
	
	NSNumberFormatter *nf = nil;
	
	NSString *wfName = [form stringForKey:@"weightFormat"];
	if ([wfName isEqualToString:@"lbs"]) {
		nf = [[WeightFormatters weightFormatter] retain];
	}

	if ([form hasKey:@"weight"]) {
		[exporter addField:EWExporterFieldWeight
					  name:[form stringForKey:@"weightName"]
				 formatter:nf];
	}
	
	if ([form hasKey:@"trendWeight"]) {
		[exporter addField:EWExporterFieldTrendWeight
					  name:[form stringForKey:@"trendWeightName"]
				 formatter:nf];
	}
	
	[nf release];
	
	if ([form hasKey:@"fat"]) {
		nf = [[NSNumberFormatter alloc] init];
		[nf setPositiveFormat:[form stringForKey:@"fatFormat"]];
		[exporter addField:EWExporterFieldFat
					  name:[form stringForKey:@"fatName"]
				 formatter:nf];
		[nf release];
	}
	
	if ([form hasKey:@"flag1"]) {
		[exporter addField:EWExporterFieldFlag1
					  name:[form stringForKey:@"flag1Name"]
				 formatter:nil];
	}
	
	if ([form hasKey:@"flag2"]) {
		[exporter addField:EWExporterFieldFlag2
					  name:[form stringForKey:@"flag2Name"]
				 formatter:nil];
	}
	
	if ([form hasKey:@"flag3"]) {
		[exporter addField:EWExporterFieldFlag3
					  name:[form stringForKey:@"flag3Name"]
				 formatter:nil];
	}
	
	if ([form hasKey:@"flag4"]) {
		[exporter addField:EWExporterFieldFlag4
					  name:[form stringForKey:@"flag4Name"]
				 formatter:nil];
	}
	
	if ([form hasKey:@"note"]) {
		[exporter addField:EWExporterFieldNote
					  name:[form stringForKey:@"noteName"]
				 formatter:nil];
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
		[NSString stringWithFormat:@"attachment; filename=\"export-%@.%@\"", 
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
