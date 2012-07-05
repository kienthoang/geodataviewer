//
//  GeoFilter.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoFilter : NSObject

- (void)userDidSelectRecordType:(NSString *)recordType;   //Add user's selection
- (void)userDidDeselectRecordType:(NSString *)recordType;

- (NSArray *)filterRecordCollection:(NSArray *)records;    //Filters the specified array of records and returns the results

@property (nonatomic,readonly) NSArray *allRecordTypes;
@property (nonatomic,strong) NSArray *selectedRecordTypes;

@end
