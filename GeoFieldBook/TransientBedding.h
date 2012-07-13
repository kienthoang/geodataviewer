//
//  TransientBedding.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientRecord.h"
#import "TransientFormation.h"

#import "Bedding.h"

@interface TransientBedding : TransientRecord

@property (nonatomic, retain) TransientFormation *formation;

@end
