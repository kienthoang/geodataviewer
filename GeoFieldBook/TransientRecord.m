//
//  TransientRecord.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
@implementation TransientRecord

@synthesize date=_date;
@synthesize project=_project;
@synthesize dateString= _dateString;
@synthesize timeString=_timeString;
@synthesize dip=_dip;
@synthesize dipDirection=_dipDirection;
@synthesize fieldOservations=_fieldOservations;
@synthesize latitude=_latitude;
@synthesize longitude=_longitude;
@synthesize name=_name;
@synthesize strike=_strike;
@synthesize folder=_folder;
@synthesize image=_image;


-(BOOL) validateDate:(NSDate *)date 
{
    return NO;
}

-(BOOL) validateDip:(NSNumber *)dip
{
    return YES;
}
-(BOOL) validateStrike:(NSNumber *)strike
{
    return YES;
}
-(BOOL) validateDipDirection:(NSString *)dipDirection 
{
    return YES;
}

@end
