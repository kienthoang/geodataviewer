//
//  MNTableViewCell.m
//  MindNodeTouch
//
//  Created by Markus Müller on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNTableViewCell.h"


@implementation MNTableViewCell

+ (id)cellForTableView:(UITableView *)tableView 
{
    NSString *cellID = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID]; 
    if (cell == nil) {
        cell = [[[self alloc] initWithCellIdentifier:cellID] autorelease]; 
    }
    return cell; 
}

+ (NSString *)cellIdentifier 
{
    return NSStringFromClass([self class]);
}


+ (UITableViewCellStyle)cellStyle
{
    return UITableViewCellStyleDefault;
}

- (id)initWithCellIdentifier:(NSString *)cellID 
{
    self = [super initWithStyle:[[self class] cellStyle] reuseIdentifier:cellID];
    if (!self) return nil;
    
    return self;
}

@end
