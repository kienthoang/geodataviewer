//
//  DataMapSegmentControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataMapSegmentViewController;

@protocol DataMapSegmentControllerDelegate <NSObject>

- (void)dataMapSegmentController:(DataMapSegmentViewController *)sender 
     isSwitchingToViewController:(UIViewController *)viewController;

@end
