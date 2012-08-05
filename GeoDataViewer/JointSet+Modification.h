//
//  JointSet+Modification.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "JointSet.h"

@interface JointSet (Modification)

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo;

@end
