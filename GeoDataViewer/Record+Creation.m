//
//  Record+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Creation.h"

@implementation Record (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inFolder:(Folder *)folder {
    Record *record=nil;
    NSManagedObjectContext *context=folder.managedObjectContext;
    
    //Get the record type
    NSString *recordType=[recordInfo objectForKey:RECORD_TYPE];
    if ([[Record allRecordTypes] containsObject:recordType]) {
        //Create a new record
        if ([recordType isEqualToString:@"Contact"]) {
            record=[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
        } else if ([recordType isEqualToString:@"Bedding"]) {
            record=[NSEntityDescription insertNewObjectForEntityForName:@"Bedding" inManagedObjectContext:context];
        } else if ([recordType isEqualToString:@"Joint Set"]) {
            record=[NSEntityDescription insertNewObjectForEntityForName:@"JointSet" inManagedObjectContext:context];
        } else if ([recordType isEqualToString:@"Other"]) {
            record=[NSEntityDescription insertNewObjectForEntityForName:@"Other" inManagedObjectContext:context];
        } else if ([recordType isEqualToString:@"Fault"]) {
            record=[NSEntityDescription insertNewObjectForEntityForName:@"Fault" inManagedObjectContext:context];
        }
        
        //Populate fields
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        record.name=[recordInfo objectForKey:RECORD_NAME];
        record.latitude=[recordInfo objectForKey:RECORD_LATITUDE];
        record.longitude=[recordInfo objectForKey:RECORD_LONGITUDE];
        record.dip=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_DIP]];
        record.strike=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_STRIKE]];
        record.dipDirection=[recordInfo objectForKey:RECORD_DIP_DIRECTION];
        record.fieldObservations=[recordInfo objectForKey:RECORD_FIELD_OBSERVATION];
        record.date=[recordInfo objectForKey:RECORD_DATE];
        
        //Update the image if it's not NSNULL
        id imageData = [recordInfo objectForKey:RECORD_IMAGE_DATA];
        if ([imageData isKindOfClass:[NSData class]]) {
            //Delete the old image
            [record.managedObjectContext deleteObject:record.image];
            
            //Set the new image
            record.image =[Image imageWithBinaryData:imageData inManagedObjectContext:record.managedObjectContext];    
        }
        
        //Set the folder
        record.folder=folder;
    }
    
    return record;
}

@end
