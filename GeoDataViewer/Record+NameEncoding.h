//
//  Record+NameEncoding.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"

@interface Record (NameEncoding)

+ (NSString *)nameForDictionaryKey:(NSString *)dictionaryKey;

@end
