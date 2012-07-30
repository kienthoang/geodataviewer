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


//used while exporting
+ (NSString *)csvCompliantStringFromString:(NSString *)text {
    //If the text is null or @"(null)" make it empty string
    if (!text || [text isEqualToString:@"(null)"])
        text=@"";
    //If any quotation marks, replace by two
    if([text componentsSeparatedByString:@"\""].count > 1) 
        text = [text stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];   

    //Now put extra quotation marks around if there is a comma, new line character or any quotation
    if ([text componentsSeparatedByString:@","].count>1 || [text componentsSeparatedByString:@"\n"].count>1 || [text componentsSeparatedByString:@"\""].count>1)
        text=[NSString stringWithFormat:@"\"%@\"",text];   

    return text;     
}


//used while importing
+ (NSString *)stringFromCSVCompliantString:(NSString *)csvCompliantString {
    //look for quotes and remove enclosing quotes
    NSRange range = NSMakeRange(1,csvCompliantString.length-2); 
    if(csvCompliantString.length>2){
        if([[csvCompliantString substringWithRange:range] componentsSeparatedByString:@"\""].count>1)
            csvCompliantString = [csvCompliantString substringWithRange:range];

        // look for commas or newlines in data and remove enclosing quotes
        if([csvCompliantString componentsSeparatedByString:@","].count >1 || [csvCompliantString componentsSeparatedByString:@"\n"].count >1){ //if commas in the token data, get rid of the enclosing quotes
            NSRange range = NSMakeRange(1,csvCompliantString.length-2);          
            csvCompliantString = [csvCompliantString substringWithRange:range];
        }
    }
    
    //Replace double quotes = 1 quote (contiguous)
    if(csvCompliantString.length>1) 
        csvCompliantString=[csvCompliantString stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""]; 
    
    return csvCompliantString;
}

@end
