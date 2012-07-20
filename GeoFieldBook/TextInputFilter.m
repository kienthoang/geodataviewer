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

+ (NSString *)csvCompliantStringFromString:(NSString *)text {
    //Put quotation marks around if there is a comma or a new line character
    if ([text componentsSeparatedByString:@","].count>1 || [text componentsSeparatedByString:@"\n"].count>1)
        text=[NSString stringWithFormat:@"\"%@\"",text];
    return text;
}

+ (NSString *)stringFromCSVCompliantString:(NSString *)csvCompliantString {
    //Strip a pair of quotation marks 
    if([csvCompliantString componentsSeparatedByString:@","].count >1 || [csvCompliantString componentsSeparatedByString:@"\n"].count >1){ //if commas in the token data, , get rid of the enclosing quotes
        NSRange range = NSMakeRange(1,csvCompliantString.length-2);           
        csvCompliantString = [csvCompliantString substringWithRange:range];
    }
    
    //Replace double quotes = 1 quote (contiguous)
    if(csvCompliantString.length>1) 
        csvCompliantString=[csvCompliantString stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""]; 
    
    return csvCompliantString;
}

@end
