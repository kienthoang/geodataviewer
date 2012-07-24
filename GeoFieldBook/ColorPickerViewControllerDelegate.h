//
//  ColorPickerViewControllerDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ColorPickerViewController;

@protocol ColorPickerViewControllerDelegate <NSObject>

- (void)colorPicker:(ColorPickerViewController *)colorPicker userDidSelectColor:(UIColor *)color withName:(NSString *)colorName;

@end
