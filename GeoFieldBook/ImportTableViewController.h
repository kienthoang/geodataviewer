//
//  ImportTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IEEngine.h"
#import "ConflictHandler.h"

#import "ImportTableViewControllerDelegate.h"

@interface ImportTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *csvFileNames;
@property (nonatomic,strong) NSArray *selectedCSVFiles;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *importButton;

@property (nonatomic,strong) IEEngine *engine;
@property (nonatomic,strong) ConflictHandler *conflictHandler;

@property (nonatomic,weak) id <ImportTableViewControllerDelegate> importDelegate;

#define SECTION_FOOTER_HEIGHT 30

@end
