//
//  IEFormatter.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "IEFormatter.h"

@implementation IEFormatter

+ (int)maximumLengthOfTwoDimensionalArray:(NSArray *)twoDimensionalArray {
    int maxLength=0;
    for (NSArray *array in twoDimensionalArray) {
        if (array.count>maxLength)
            maxLength=array.count;
    }
    
    return maxLength;
}

+ (NSArray *)transposeTwoDimensionalArray:(NSArray *)twoDimensionalArray {
    //Get the maximum length of the 2d array
    int maxLength=[self maximumLengthOfTwoDimensionalArray:twoDimensionalArray];
    
    //Start transponsing
    NSMutableArray *transposed2DArray=[NSMutableArray arrayWithCapacity:maxLength];
    for (int i=0;i<maxLength;i++) {
        NSMutableArray *entry=[NSMutableArray arrayWithCapacity:twoDimensionalArray.count];
        for (NSArray *array in twoDimensionalArray)
            [entry addObject:(i<array.count ? [array objectAtIndex:i] : @"")];
        
        [transposed2DArray addObject:entry.copy];
    }
    
    return transposed2DArray.copy;
}

@end
