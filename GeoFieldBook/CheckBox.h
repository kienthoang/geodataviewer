//
//  CheckBox.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBox : UIImageView

@property (nonatomic, strong) UIImage *checked;
@property (nonatomic, strong) UIImage *unchecked;
@property (nonatomic) BOOL isChecked;

#define CHECK_BOX_ANIMATION_DURATION 0.4

@end
