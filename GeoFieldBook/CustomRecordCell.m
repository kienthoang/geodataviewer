//
//  CustomRecordCell.m
//  GeoFieldBook
//
//  Created by excel 2011 on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomRecordCell.h"

@implementation CustomRecordCell

@synthesize name = _name;
@synthesize date = _date;
@synthesize time = _time;
@synthesize image = _image;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
