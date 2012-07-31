//
//  StrikePickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class StrikePickerViewController;

@protocol StrikePickerDelegate <NSObject>

- (void)strikePickerViewController:(StrikePickerViewController *)sender 
          userDidSelectStrikeValue:(NSString *)strike;

@end

@interface StrikePickerViewController : PickerViewController

@property (nonatomic,weak) id <StrikePickerDelegate> delegate;

@end
