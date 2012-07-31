//
//  Answer+Creation.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer+Creation.h"

@implementation Answer (Creation)

+ (Answer *)answerForInfo:(NSDictionary *)answerInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Create a new question with the given info
    Answer *answer=[NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:context];
    answer.content=[answerInfo objectForKey:ANSWER_CONTENT];
    answer.date=[answerInfo objectForKey:ANSWER_DATE];
    answer.numberOfRecords=[answerInfo objectForKey:ANSWER_NUM_RECORDS];
    answer.question=[answerInfo objectForKey:ANSWER_QUESTION];
    
    //update answer location
    CLLocation *location=[answerInfo objectForKey:ANSWER_LOCATION];
    CLLocationCoordinate2D coordinate=location.coordinate;
    CLLocationDegrees latitude=coordinate.latitude;
    CLLocationDegrees longitude=coordinate.longitude;
    answer.latitude=[NSNumber numberWithFloat:latitude];
    answer.longitude=[NSNumber numberWithFloat:longitude];
    
    return answer;
}

@end
