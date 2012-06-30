//
//  Record+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Modification.h"
#import "Image+Creation.h"

@implementation Record (Modification)

- (void)updateWithNewRecordInfo:(NSDictionary *)recordInfo 
{
    //Update info
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    self.name=[recordInfo objectForKey:RECORD_NAME];
    self.latitude=[recordInfo objectForKey:RECORD_LATITUDE];
    self.longitude=[recordInfo objectForKey:RECORD_LONGITUDE];
    self.dip=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_DIP]];
    self.strike=[numberFormatter numberFromString:[recordInfo objectForKey:RECORD_STRIKE]];
    self.dipDirection=[recordInfo objectForKey:RECORD_DIP_DIRECTION];
    self.fieldOservations=[recordInfo objectForKey:RECORD_FIELD_OBSERVATION];
    self.date=[recordInfo objectForKey:RECORD_DATE];
    
    //Update the image if it's not NSNULL
    id imageData = [recordInfo objectForKey:RECORD_IMAGE_DATA];
    if ([imageData isKindOfClass:[NSData class]])
        self.image = [Image imageWithBinaryData:imageData inManagedObjectContext:self.managedObjectContext];    
}

@end
