//
//  ColorManager.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorManager : NSObject


+ (ColorManager *)standardColorManager;

- (UIColor *)colorWithName:(NSString *)colorName;
- (NSString *)nameForColor:(UIColor *)color;

@end
