//
//  ColorPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "NPColorPickerView.h"
#import "ColorPickerViewControllerDelegate.h"

@interface ColorPickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet NPColorPickerView *colorPickerView;
@property (weak, nonatomic) id <ColorPickerViewControllerDelegate> delegate;

@property (nonatomic,strong) UIColor *selectedColor;

@end
