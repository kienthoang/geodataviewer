//
//  TransientRecord.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientRecord.h"
#import "TransientImage.h"
#import "Record+DipDirectionValues.h"

#import "TransientBedding.h"
#import "TransientContact.h"
#import "TransientFault.h"
#import "TransientJointSet.h"
#import "TransientOther.h"

@implementation TransientRecord

@synthesize date=_date;
@synthesize project=_project;
@synthesize dip=_dip;
@synthesize dipDirection=_dipDirection;
@synthesize fieldOservations=_fieldOservations;
@synthesize latitude=_latitude;
@synthesize longitude=_longitude;
@synthesize name=_name;
@synthesize strike=_strike;
@synthesize folder=_folder;
@synthesize image=_image;

@synthesize nsManagedRecord=_nsManagedRecord;

#pragma mark - Database Operations

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    if (self.nsManagedRecord) {
        //Save attributes
        Record *record=self.nsManagedRecord;
        record.name=self.name;
        record.date=self.date;
        record.strike=self.strike;
        record.dip=self.dip;
        record.dipDirection=self.dipDirection;
        record.fieldObservations=self.fieldOservations;
        record.latitude=self.latitude;
        record.longitude=self.longitude;
        
        //Associate with the folder
        record.folder=[self.folder saveFolderToManagedObjectContext:context];
        
        //Associate with the image
        record.image=[self.image saveImageToManagedObjectContext:context completion:^(NSManagedObject *obj){}];
    }
}

#pragma mark - Setters with Validations

- (NSString *)setDipWithValidations:(NSString *)dipString {
    //Convert the dip string into a number
    if (dipString.length) {
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        self.dip=[numberFormatter numberFromString:dipString];
        
        //If that fails or the dip value is not in the allowed range, return an error message
        return (self.dip &&  TransientRecordMinimumDip<=self.dip.intValue && self.dip.intValue<=TransientRecordMaximumDip) ? nil : [NSString stringWithFormat:@"Dip value of record with name \"%@\" is invalid",self.name];
    } 
    
    return nil;
}

- (NSString *)setStrikeWithValidations:(NSString *)strikeString {
    //Convert the given string into a number
    if (strikeString.length) {
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        self.strike=[numberFormatter numberFromString:strikeString];
        
        //If that fails or the strike value is not in the range 0-360, return an error message
        return (self.strike &&  TransientRecordMinimumStrike<=self.strike.intValue && self.strike.intValue<=TransientRecordMaximumStrike) ? nil : [NSString stringWithFormat:@"Strike value of record with name \"%@\" is invalid",self.name];
    }
    
    return nil;
}

- (NSString *)setFieldObservationWithValidations:(NSString *)fieldObservation {
    //NO VALIDATION YET
    self.fieldOservations=fieldObservation;
    
    return nil;
}

- (NSString *)setDipDirectionWithValidations:(NSString *)dipDirection {
    //If the given dip direction is not empty and in the allowed dip direction value list, report an error
    NSArray *allowedDipDirectionValues=[Record allDipDirectionValues];
    if (dipDirection.length && ![allowedDipDirectionValues containsObject:dipDirection])
        return [NSString stringWithFormat:@"Unrecognized dip direction for record with name \"%@\"",self.name];
    
    //Else save the dip direction
    self.dipDirection=dipDirection;
    
    return nil;
}

- (NSString *)setLatitudeWithValidations:(NSString *)latitude {
    //If the given latitude is not a number, return the error message
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    if (![numberFormatter numberFromString:latitude])
        return [NSString stringWithFormat:@"Latitude of record with name \"%@\" is invalid.",self.name];
    
    //Else save it
    self.latitude=latitude;
    
    //If the latitude value is not in the appropriate range, return an error message
    return (TransientRecordMinimumLatitude<=self.latitude.intValue && self.latitude.intValue<=TransientRecordMaximumLatitude) ? nil : [NSString stringWithFormat:@"Latitude value of record with name \"%@\" is invalid",self.name];
}

- (NSString *)setLongitudeWithValidations:(NSString *)longitude {
    //If the given longitude is not a number, return the error message
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    if (![numberFormatter numberFromString:longitude])
        return [NSString stringWithFormat:@"Longitude of record with name \"%@\" is invalid.",self.name];
    
    //Else save it
    self.longitude=longitude;
    
    //If the longitude value is not in the appropriate range, return an error message
    return (TransientRecordMinimumLongitude<=self.longitude.intValue && self.longitude.intValue<=TransientRecordMaximumLongitude) ? nil : [NSString stringWithFormat:@"Longitude value of record with name \"%@\" is invalid",self.name];
}

#pragma mark - Convenience methods

+ (TransientRecord *)recordWithType:(NSString *)recordType {    
    if([recordType isEqualToString:@"Contact"])
        return [[TransientContact alloc] init];
    else if([recordType isEqualToString:@"Bedding"])
        return [[TransientBedding alloc] init];
    else if([recordType isEqualToString:@"Fault"])
        return [[TransientFault alloc] init];
    else if([recordType isEqualToString:@"Joint Set"])
        return [[TransientContact alloc] init];
    else if([recordType isEqualToString:@"Other"])
        return [[TransientOther alloc] init];
        
    return nil;
}

@end
