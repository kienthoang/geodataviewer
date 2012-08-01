//
//  TransientContact.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
#import "TransientFormation.h"

#import "Contact.h"

@interface TransientContact : TransientRecord

@property (nonatomic, strong) TransientFormation *lowerFormation;
@property (nonatomic, strong) TransientFormation *upperFormation;

@end
