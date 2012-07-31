//
//  MNColorTableViewCell.h
//  MindNodeTouch
//
//  Created by Markus Müller on 10.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNTableViewCell.h"

@class MNColorView;

@interface MNColorTableViewCell : MNTableViewCell 

@property (readwrite, retain) MNColorView *colorView;

@end
