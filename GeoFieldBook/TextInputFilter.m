//
//  TextInputFilter.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TextInputFilter.h"

@implementation TextInputFilter

+ (BOOL)isSafeForDatabaseInputText:(NSString *)text {
    return YES;
}

+ (NSString *)filterDatabaseInputText:(NSString *)text {
    //Format the text input
    NSString *filteredText=nil;
    if ([self isSafeForDatabaseInputText:text]) {
        filteredText=text;
        
        //Trim leading and trailing spaces and new lines
        filteredText=[filteredText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return filteredText;
        
}

@end
