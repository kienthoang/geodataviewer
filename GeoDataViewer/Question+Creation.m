//
//  Question+Creation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question+Creation.h"

@implementation Question (Creation)

+ (Question *)questionForPrompt:(NSString *)prompt inManagedObjectContext:(NSManagedObjectContext *)context {
    //Create a new question
    Question *question=[NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:context];
    question.prompt=prompt;
    
    return question;
}

@end
