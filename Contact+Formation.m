//
//  Contact+Formation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Contact+Formation.h"

@implementation Contact (Formation)

- (Formation *) formationColor
{
    return self.upperFormation ? self.upperFormation : self.lowerFormation;
}

@end
