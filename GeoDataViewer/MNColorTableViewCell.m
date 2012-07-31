//
//  MNColorTableViewCell.m
//  MindNodeTouch
//
//  Created by Markus Müller on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNColorTableViewCell.h"
#import "MNColorView.h"

@implementation MNColorTableViewCell


#pragma mark - Properties

@synthesize colorView = _colorView;

#pragma mark - NSObject

- (id)initWithCellIdentifier:(NSString *)cellID 
{
    self = [super initWithCellIdentifier:cellID];
    if (!self) return nil;
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    self.colorView = [[[MNColorView alloc] initWithFrame:CGRectZero] autorelease];
    self.colorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.colorView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.colorView];
    
    return self;
}


- (void)dealloc
{
    MNRelease(_colorView);
    
    [super dealloc];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect colorFrame = CGRectMake(self.contentView.frame.size.width - 90, (self.contentView.frame.size.height - 30)/2+0.5, 80, 30);
    self.colorView.frame = colorFrame;
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.size.width -= 140.0f;
    self.textLabel.frame = textFrame;
}
@end
