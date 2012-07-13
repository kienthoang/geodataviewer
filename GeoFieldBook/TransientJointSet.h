//
//  TransientJointSet.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
#import "TransientFormation.h"

#import "JointSet.h"

@interface TransientJointSet : TransientRecord
@property (nonatomic, strong) TransientFormation *formation;

@end
