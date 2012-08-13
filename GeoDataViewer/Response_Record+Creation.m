//
//  Response_Record+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Response_Record+Creation.h"

@implementation Response_Record (Creation)

+ (Response_Record *)responseRecordInManagedObjectContext:(NSManagedObjectContext *)context {
    Response_Record *record=[NSEntityDescription insertNewObjectForEntityForName:@"Response_Record" inManagedObjectContext:context];
    
    return record;
}

@end
