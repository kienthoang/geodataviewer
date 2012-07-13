//
//  TransientRecord.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
#import "Record+DipDirectionValues.h"

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

- (NSString *)setDipWithValidations:(NSString *)dipString {
    //Convert the dip string into a number
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    self.dip=[numberFormatter numberFromString:dipString];
    
    //If that fails or the dip value is not in the allowed range, return an error message
    return (self.dip &&  TransientRecordMinimumDip<=self.dip.intValue && self.dip.intValue<=TransientRecordMaximumDip) ? nil : [NSString stringWithFormat:@"Dip value of record with name %@ is invalid",self.name];
}

- (NSString *)setStrikeWithValidations:(NSString *)strikeString {
    //Convert the given string into a number
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    self.dip=[numberFormatter numberFromString:strikeString];
    
    //If that fails or the strike value is not in the range 0-360, return an error message
    return (self.strike &&  TransientRecordMinimumStrike<=self.strike.intValue && self.strike.intValue<=TransientRecordMaximumStrike) ? nil : [NSString stringWithFormat:@"Strike value of record with name %@ is invalid",self.name];
}

- (NSString *)setFieldObservationWithValidations:(NSString *)fieldObservation {
    //NO VALIDATION YET
    self.fieldOservations=fieldObservation;
    
    return nil;
}

- (NSString *)setDipDirectionWithValidations:(NSString *)dipDirection {
    //If the given dip direction is not in the allowed dip direction value list, report an error
    NSArray *allowedDipDirectionValues=[Record allDipDirectionValues];
    if (![allowedDipDirectionValues containsObject:dipDirection])
        return [NSString stringWithFormat:@"Unrecognized dip direction for record with name %@",self.name];
    
    //Else save the dip direction
    self.dipDirection=dipDirection;
    
    return nil;
}

- (NSString *)setLatitudeWithValidations:(NSString *)latitude {
    //If the given latitude is not a number, return the error message
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    if (![numberFormatter numberFromString:latitude])
        return [NSString stringWithFormat:@"Latitude of record with name %@ is invalid.",self.name];
    
    //Else save it
    self.latitude=latitude;
    return nil;
}

- (NSString *)setLongitudeWithValidations:(NSString *)longitude {
    //If the given longitude is not a number, return the error message
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    if (![numberFormatter numberFromString:longitude])
        return [NSString stringWithFormat:@"Longitude of record with name %@ is invalid.",self.name];
    
    //Else save it
    self.longitude=longitude;
    return nil;
}

@end
