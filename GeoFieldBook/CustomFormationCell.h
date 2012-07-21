//
//  CustomFormationCell.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Formation.h"

@interface CustomFormationCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UIButton *colorPatch;
@property (nonatomic,strong) Formation *formation;

@end
