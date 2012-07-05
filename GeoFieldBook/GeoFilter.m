//
//  GeoFilter.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFilter.h"
#import "Record.h"
#import "Record+Types.h"

@interface GeoFilter()

@end

@implementation GeoFilter

@synthesize selectedRecordTypes=_selectedRecordTypes;

#pragma mark - Getters and Setters

- (NSArray *)allRecordTypes {
    return [Record allRecordTypes];
}

- (NSArray *)selectedRecordTypes {
    if (!_selectedRecordTypes)
        _selectedRecordTypes=self.allRecordTypes;
    
    return _selectedRecordTypes;
}

#pragma mark - Select/Deselect Record Types

- (void)userDidSelectRecordType:(NSString *)recordType {
    //Add the selected record type to the array of selected record types
    if (![self.selectedRecordTypes containsObject:recordType]) {
        NSMutableArray *selectedRecordTypes=[self.selectedRecordTypes mutableCopy];
        [selectedRecordTypes addObject:recordType];
        self.selectedRecordTypes=[selectedRecordTypes copy];
    }
}

- (void)userDidDeselectRecordType:(NSString *)recordType {
    //Remove the selected record type from the array of selected record types
    if ([self.selectedRecordTypes containsObject:recordType]) {
        NSMutableArray *selectedRecordTypes=[self.selectedRecordTypes mutableCopy];
        [selectedRecordTypes removeObject:recordType];
        self.selectedRecordTypes=[selectedRecordTypes copy];
    }
}

#pragma mark - Filter Mechanisms

- (NSArray *)filterRecordCollection:(NSArray *)records {
    //iterate through the given records and filter out records of types that were not selected by the user
    NSMutableArray *filteredRecords=[records mutableCopy];
    for (Record *record in records) {
        if (![self.selectedRecordTypes containsObject:[record.class description]])
            [filteredRecords removeObject:record];
    }
    
    return [filteredRecords copy];
}

@end
