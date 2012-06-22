//
//  TextInputFilter.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextInputFilter : NSObject

+ (BOOL)isSafeForDatabaseInputText:(NSString *)text;       //returns true if the text contains no unsafe parts
+ (NSString *)filterDatabaseInputText:(NSString *)text;    //returns nil if the text contains too many unsafe parts

@end
