//
//  Answer+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer+Creation.h"

#import "Response_Record.h"

@implementation Answer (Creation)

+ (Answer *)responseForInfo:(NSDictionary *)responseInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    //Get all the information from the info dictionary
    Answer *response=[NSEntityDescription insertNewObjectForEntityForName:@"Answer" inManagedObjectContext:context];
    
    //Populate the fields of the response
    response.content=[responseInfo objectForKey:GDVStudentResponseContent];
    response.date=[responseInfo objectForKey:GDVStudentResponseDate];
    response.latitude=[responseInfo objectForKey:GDVStudentResponseLatitude];
    response.longitude=[responseInfo objectForKey:GDVStudentResponseLongitude];
    response.numberOfRecords=[responseInfo objectForKey:GDVStudentResponseNumRecords];
    
    //Set the question of the response
    response.question=[Question questionForPrompt:[responseInfo objectForKey:GDVStudentResponseQuestionPrompt] inManagedObjectContext:context];
    
    //Set the response record of the response
    Response_Record *record=[responseInfo objectForKey:GDVStudentResponseResponseRecord];
    response.responseRecord=record;
    record.latitude=response.latitude;
    record.longitude=response.longitude;
    record.date=response.date;
    
    return response;
}

@end
