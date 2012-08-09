//
//  CustomStudentGroupCell.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Group.h"

#pragma mark - protocol for segueing to the npColorPicker when patch pressed
@class CustomStudentGroupCell;
@protocol CustomStudentGroupCellDelegate <NSObject>

-(void) colorPatchPressedWithColorRGB:(UIColor *) backgroundColor andSender:(CustomStudentGroupCell *)cell;
@end


@interface CustomStudentGroupCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UILabel *groupID;
@property (nonatomic,weak) IBOutlet UIButton *colorPatch;
@property (nonatomic,strong) Group *studentGroup;
@property (nonatomic, strong) id <CustomStudentGroupCellDelegate> delegate;

-(void) updatePatchColor:(UIColor *) color;

@end
