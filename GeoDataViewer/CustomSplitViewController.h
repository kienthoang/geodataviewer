//
//  CustomSplitViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomSplitViewControllerChildren.h"

@interface CustomSplitViewController : UIViewController

@property (nonatomic,strong) UIViewController *masterViewController;
@property (nonatomic,strong) UIViewController *detailViewController;

#define CustomSplitViewControllerMasterSegueIdentifier @"masterViewController"
#define CustomSplitViewControllerDetailSegueIdentifier @"detailViewController"

@end
