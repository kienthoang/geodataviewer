//
//  TransientFault.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFault.h"

@implementation TransientFault

@synthesize plunge;
@synthesize trend;
@synthesize formation;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context 
                        completion:(completion_handler_t)completionHandler
{
    //Create a fault record
    self.nsManagedRecord=[NSEntityDescription insertNewObjectForEntityForName:@"Fault" inManagedObjectContext:context];
    
    //Call super to populate the common record info
    [super saveToManagedObjectContext:context completion:completionHandler];
    
    //Populate formation
    Fault *fault=(Fault *)self.nsManagedRecord;
    [fault setFormation:[self.formation saveFormationToManagedObjectContext:context]];
    
    //Set plunge and trend
    fault.trend=self.trend;
    fault.plunge=self.plunge;
    
    //Call completion handler
    completionHandler(self.nsManagedRecord);
}

- (NSString *)setPlungeWithValidations:(NSString *)plungeString {
    //Convert the plunge string into a number
    if (plungeString.length) {
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        self.plunge=[numberFormatter numberFromString:plungeString];
        
        //If that fails or the plunge value is not in the allowed range, return an error message
        return (self.plunge &&  TransientRecordMinimumPlunge<=self.plunge.intValue && self.plunge.intValue<=TransientRecordMaximumPlunge) ? nil : [NSString stringWithFormat:@"Plunge value of record with name \"%@\" is invalid",self.name];
    } 
    
    return nil;
}

- (NSString *)setTrendWithValidations:(NSString *)trendString {
    //Convert the given string into a number
    if (trendString.length) {
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        self.trend=[numberFormatter numberFromString:trendString];
        
        //If that fails or the trend value is not in the range, return an error message
        return (self.trend &&  TransientRecordMinimumTrend<=self.trend.intValue && self.trend.intValue<=TransientRecordMaximumTrend) ? nil : [NSString stringWithFormat:@"Trend value of record with name \"%@\" is invalid",self.name];
    } 
    
    return nil;
}

@end
