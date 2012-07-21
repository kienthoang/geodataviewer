//
//  ImportTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "IEEngine.h"
#import "ConflictHandler.h"

#import "ImportTableViewControllerDelegate.h"

@interface ImportTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *csvFileNames;
@property (nonatomic,strong) NSArray *selectedCSVFiles;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *importButton;

@property (nonatomic,strong) IEEngine *engine;
@property (nonatomic,strong) ConflictHandler *conflictHandler;

@property (nonatomic,weak) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *addButton;

@property (nonatomic,strong) NSString *csvFileExtension;

#define SECTION_FOOTER_HEIGHT 30
#define SizeInPopover CGRectMake(0,0,400,500).size

- (IBAction)importPressed:(UIBarButtonItem *)sender;

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo;

- (void)synchronizeWithFileSystem;

@end
