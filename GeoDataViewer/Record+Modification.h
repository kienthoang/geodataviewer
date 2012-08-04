//
//  Record+Modification.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"
#import "Record+DictionaryKeys.h"
#import "Bedding+Modification.h"
#import "Contact+Modification.h"
#import "Fault+Modification.h"
#import "JointSet+Modification.h"

@interface Record (Modification)

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo;        //Updates self with the user-modified record info dictionary, whose keys are specified in Record+DictionaryKeys.h as macros

@end
