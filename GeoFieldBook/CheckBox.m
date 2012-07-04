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


-(void) awakeFromNib {
    [super awakeFromNib];
    //set up the images
    self.checked = [UIImage imageNamed:@"checked.png"];
    self.unchecked = [UIImage imageNamed:@"unchecked.png"];
    self.image = self.checked;
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self action:@selector(toggle:)];
    [self addGestureRecognizer:tgr];
}

-(void) viewDidLoad {
    
}
-(void) toggle:(UITapGestureRecognizer *)tgr {
    self.isChecked=!self.isChecked;
    self.image = self.isChecked ? self.checked : self.unchecked;
}

@end
