//
//  EWWiFiAccessViewController.m
//  EatWatch
//
//  Created by Benjamin Ragheb on 6/21/09.
//  Copyright 2009 Benjamin Ragheb. All rights reserved.
//

#import "EWWiFiAccessViewController.h"

#import "RootViewController.h"
#import "BRReachability.h"
#import "MicroWebServer.h"
#import "EWDatabase.h"
#import "EWDBMonth.h"
#import "WeightFormatters.h"
#import "CSVReader.h"
#import "CSVWriter.h"
#import "EWGoal.h"
#import "FormDataParser.h"


#define HTTP_STATUS_OK 200
#define HTTP_STATUS_NOT_FOUND 404


NSDateFormatter *EWDateFormatterGetISO() {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat:@"y-MM-dd"];
	return [formatter autorelease];
}


NSDateFormatter *EWDateFormatterGetLocal() {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
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
								  flag:flag
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
	[connection setResponseStatus:HTTP_STATUS_NOT_FOUND];
	[connection setValue:@"text/plain" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyString:@"Resource Not Found"];
}


- (void)sendHTMLResourceNamed:(NSString *)name withSubstitutions:(NSDictionary *)substitutions toConnection:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
	
	if (path == nil) {
		[self sendNotFoundErrorToConnection:connection];
		return;
	}
	
	NSMutableString *text = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	for (NSString *key in [substitutions allKeys]) {
		[text replaceOccurrencesOfString:key
							  withString:[substitutions objectForKey:key]
								 options:0
								   range:NSMakeRange(0, [text length])];
	}
	
	[connection setResponseStatus:HTTP_STATUS_OK];
	[connection setValue:@"text/html; charset=utf-8" forResponseHeader:@"Content-Type"];
	[connection setResponseBodyData:[text dataUsingEncoding:NSUTF8StringEncoding]];
	
	[text release];
}


- (void)sendResource:(NSString *)name ofType:(NSString *)type contentType:(NSString *)contentType toConnection:(MicroWebConnection *)connection {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
	
	if (path == nil) {
		[self sendNotFoundErrorToConnection:connection];
		return;
	}
	
	[connection setResponseStatus:HTTP_STATUS_OK];
	[connection setValue:contentType forResponseHeader:@"Content-Type"];
	[connection setResponseBodyData:[NSData dataWithContentsOfFile:path]];
}


- (void)handleExport:(MicroWebConnection *)connection {
	CSVWriter *writer = [[CSVWriter alloc] init];
	writer.floatFormatter = [WeightFormatters exportWeightFormatter];
	
	[writer addString:@"Date"];
	[writer addString:@"Weight"];
	[writer addString:@"Checkmark"];
	[writer addString:@"Note"];
	[writer endRow];
	
	NSDateFormatter *formatter = EWDateFormatterGetISO();
	
	EWDatabase *db = [EWDatabase sharedDatabase];
	EWMonth month;
	for (month = db.earliestMonth; month <= db.latestMonth; month += 1) {
		EWDBMonth *md = [db getDBMonth:month];
		EWDay day;
		for (day = 1; day <= 31; day++) {
			if ([md hasDataOnDay:day]) {
				struct EWDBDay *dd = [md getDBDay:day];
				[writer addString:[formatter stringFromDate:[md dateOnDay:day]]];
				[writer addFloat:dd->scaleWeight];
				[writer addBoolean:(dd->flags != 0)];
				[writer addString:dd->note];
				[writer endRow];
			}
		}
	}
	
	NSString *contentType = @"text/csv; charset=utf-8";
	NSString *contentDisposition = [NSString stringWithFormat:@"attachment; filename=\"weight-%@.csv\"", [formatter stringFromDate:[NSDate date]]];
	
	[connection setResponseStatus:HTTP_STATUS_OK];
	[connection setValue:contentType forResponseHeader:@"Content-Type"];
	[connection setValue:contentDisposition forResponseHeader:@"Content-Disposition"];
	[connection setResponseBodyData:[writer data]];
	[writer release];

	[self setCurrentDateForKey:kEWLastExportKey];
}


- (void)handleImport:(MicroWebConnection *)connection {
	if (importData != nil) {
		// If we are already waiting for imported data to be handled, ignore
		// further requests.
		[self sendHTMLResourceNamed:@"importPending" 
				  withSubstitutions:nil
					   toConnection:connection];
		return;
	}
	
	FormDataParser *form = [[FormDataParser alloc] initWithConnection:connection];
	importData = [[form dataForKey:@"filedata"] retain];
	importEncoding = [[form stringForKey:@"encoding"] intValue];
	[form release];
	
	if (importData == nil) {
		[self sendHTMLResourceNamed:@"importNoData" 
				  withSubstitutions:nil
					   toConnection:connection];
		return;
	}
	
	[self displayDetailView:promptDetailView];
		
	[self sendHTMLResourceNamed:@"importAccepted"
			  withSubstitutions:nil
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
	
	if ([path isEqualToString:@"/"]) {
		UIDevice *device = [UIDevice currentDevice];
		NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
		NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
		NSString *copyright = [info objectForKey:@"NSHumanReadableCopyright"];
		NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:
							   [device name], @"__NAME__",
							   [device localizedModel], @"__MODEL__",
							   version, @"__VERSION__",
							   copyright, @"__COPYRIGHT__",
							   nil];
		[self sendHTMLResourceNamed:@"home" 
				  withSubstitutions:subst
					   toConnection:connection];
		return;
	}
	
	if ([path hasPrefix:@"/export/"]) {
		[self handleExport:connection];
		return;
	}
	
	if ([path isEqualToString:@"/import"]) {
		[self handleImport:connection];
		return;
	}
	
	if ([path isEqualToString:@"/icon.png"]) {
		[self sendResource:@"Icon" ofType:@"_png" 
			   contentType:@"image/png" toConnection:connection];
		return;
	}
	
	if ([path isEqualToString:@"/fatwatch.css"]) {
		[self sendResource:@"fatwatch" ofType:@"css" 
			   contentType:@"text/css" toConnection:connection];
		return;
	}
	
	// handle robots.txt, favicon.ico
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
