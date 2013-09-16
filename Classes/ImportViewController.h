//
//  ImportViewController.h
//  EatWatch
//
//  Created by Benjamin Ragheb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWImporter.h"

@interface ImportViewController : UIViewController <EWImporterDelegate, UIActionSheetDelegate>
{
    @private
    UILabel *titleLabel;
    UIProgressView *importProgressView;
    UILabel *detailLabel;
    UIButton *okButton;
    EWImporter *importer;
    EWDatabase *database;
    BOOL promptBeforeImport;
}
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *importProgressView;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UIButton *okButton;
@property (nonatomic) BOOL promptBeforeImport;
- (id)initWithImporter:(EWImporter *)theImporter database:(EWDatabase *)db;
- (IBAction)okAction;
@end
