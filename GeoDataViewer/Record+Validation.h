//
//  Record+Validation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"
#import "Record+DictionaryKeys.h"

@interface Record (Validation)

//Return an array of record dictionary keys that correspond to missing information
- (NSArray *)validatesMandatoryPresenceOfRecordInfo:(NSDictionary *)recordInfo;

@end
