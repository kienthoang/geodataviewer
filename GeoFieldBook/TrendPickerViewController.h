//
//  TrendPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class TrendPickerViewController;

@protocol TrendPickerDelegate <NSObject>

- (void)trendPickerViewController:(TrendPickerViewController *)sender 
          userDidSelectTrendValue:(NSString *)trend;

@end

@interface TrendPickerViewController : PickerViewController

@property (nonatomic,weak) id <TrendPickerDelegate> delegate;

@end
