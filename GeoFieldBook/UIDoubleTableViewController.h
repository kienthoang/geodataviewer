//
//  UIDoubleTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDoubleTableViewControllerChildren.h"

@interface UIDoubleTableViewController : UIViewController

@property (nonatomic,strong) UITableViewController *masterTableViewController;
@property (nonatomic,strong) UITableViewController *detailTableViewController;

#define DoubleTableViewControllerMasterSegueIdentifier @"masterTableViewController"
#define DoubleTableViewControllerDetailSegueIdentifier @"detailTableViewController"

@end
