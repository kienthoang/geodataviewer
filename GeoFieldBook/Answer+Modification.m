//
//  Answer+Modification.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer+Modification.h"

@implementation Answer (Modification)

- (void)updateWithInfo:(NSDictionary *)answerInfo {
    //Create a new question with the given info
    self.content=[answerInfo objectForKey:ANSWER_CONTENT];
    self.date=[answerInfo objectForKey:ANSWER_DATE];
    self.numberOfRecords=[answerInfo objectForKey:ANSWER_NUM_RECORDS];
    self.question=[answerInfo objectForKey:ANSWER_QUESTION];    
    
    //update answer location
    CLLocation *location=[answerInfo objectForKey:ANSWER_LOCATION];
    CLLocationCoordinate2D coordinate=location.coordinate;
    CLLocationDegrees latitude=coordinate.latitude;
    CLLocationDegrees longitude=coordinate.longitude;
    self.latitude=[NSNumber numberWithFloat:latitude];
    self.longitude=[NSNumber numberWithFloat:longitude];
}

@end
