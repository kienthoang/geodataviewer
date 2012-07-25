//
//  ColorManager.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorManager : NSObject

-(UIColor *) colorWithName:(NSString *) colorName;

@property (nonatomic, strong) NSDictionary *colorDictionary;

@end
