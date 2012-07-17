//
//  MNTableViewCell.h
//  MindNodeTouch
//
//  Created by Markus Müller on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MNTableViewCell : UITableViewCell 

+ (NSString *)cellIdentifier;
+ (UITableViewCellStyle)cellStyle;
+ (id)cellForTableView:(UITableView *)tableView;
- (id)initWithCellIdentifier:(NSString *)cellID;

@end
