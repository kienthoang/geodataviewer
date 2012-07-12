//
//  ImportTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportTableViewController : UITableViewController

@property (nonatomic,strong) NSArray *csvFileNames;
@property (nonatomic,strong) NSArray *selectedCSVFiles;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;

#define SECTION_FOOTER_HEIGHT 30

@end
