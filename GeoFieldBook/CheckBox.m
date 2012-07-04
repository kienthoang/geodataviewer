//
//  CheckBox.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox
@synthesize checked = _checked;
@synthesize unchecked = _unchecked;
@synthesize isChecked = _isChecked;

- (id)initWithFrame:(CGRect)frame
{   
    NSLog(@"initwithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"checked.png"];
    }
    return self;
}


@end
