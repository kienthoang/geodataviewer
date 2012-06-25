//
//  PlungePickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class PlungePickerViewController;

@protocol PlungePickerDelegate <NSObject>

- (void)plungePickerViewController:(PlungePickerViewController *)sender 
          userDidSelectPlungeValue:(NSString *)plunge;

@end

@interface PlungePickerViewController : PickerViewController

@property (nonatomic,weak) id <PlungePickerDelegate> delegate;

@end
