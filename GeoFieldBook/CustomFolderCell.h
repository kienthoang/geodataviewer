//
//  CustomFolderCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"

@interface CustomFolderCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subTitie;
@property (nonatomic,weak) IBOutlet UIImageView *checkBox;

@end
