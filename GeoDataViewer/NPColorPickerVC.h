//
//  NPColorPickerVC.h
//  GeoDataViewer
//
//  Created by excel 2011 on 8/6/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPColorPickerView.h"
#import "NPColorQuadView.h"


@class NPColorPickerVC;

@protocol NPColorPickerVCDelegate <NSObject>

-(void) userDidDismissPopoverWithColor:(UIColor *) color;

@end


@interface NPColorPickerVC : UIViewController
@property (weak, nonatomic) IBOutlet NPColorPickerView *picker;
@property (weak, nonatomic) IBOutlet NPColorQuadView *quad;
@property (nonatomic, strong) id <NPColorPickerVCDelegate> delegate;

@end
