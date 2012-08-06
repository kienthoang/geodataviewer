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

@interface CustomStudentGroupCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UIButton *colorPatch;
@property (nonatomic,strong) Group *studentGroup;

@end
