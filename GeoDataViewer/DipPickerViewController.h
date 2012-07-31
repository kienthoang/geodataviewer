//
//  DipPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class DipPickerViewController;

@protocol DipPickerDelegate <NSObject>

- (void)dipPickerViewController:(DipPickerViewController *)sender 
          userDidSelectDipValue:(NSString *)dip;

@end

@interface DipPickerViewController : PickerViewController

@property (nonatomic,weak) id <DipPickerDelegate> delegate;

@end
