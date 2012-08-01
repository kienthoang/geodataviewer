//
//  CustomRecordCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"

@interface CustomRecordCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UIImageView *recordImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *type;
@property (nonatomic, weak) IBOutlet CheckBox *checkBox;

- (void)showCheckBoxAnimated:(BOOL)animated;
- (void)hideCheckBoxAnimated:(BOOL)animated;

@end
