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
@synthesize recordImageView = _recordImageView;
@synthesize type = _type;
@synthesize checkBox = _checkBox;

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self.checkBox action:@selector(toggle:)];
    [self.checkBox addGestureRecognizer:tgr];
}

@end
