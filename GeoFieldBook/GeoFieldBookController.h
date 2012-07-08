//
//  GeoFieldBookController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataMapSegmentViewControllerDelegate.h"
#import "RecordTableViewControllerDelegate.h"

@interface GeoFieldBookController : UIViewController <DataMapSegmentViewControllerDelegate>

@property (nonatomic,strong) UIPopoverController *popoverViewController;
@property (nonatomic,strong) UIViewController *viewGroupController;

@end
