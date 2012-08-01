//
//  DipStrikeSymbol.h
//  Test
//
//  Created by excel2011 on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DipStrikeSymbol : UIView

@property (nonatomic) float strike;
@property (nonatomic) float dip;
@property (nonatomic, strong) NSString *dipDirection;
@property (nonatomic, strong) UIColor *color;

@end
