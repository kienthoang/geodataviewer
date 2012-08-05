//
//  Question+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question.h"

@interface Question (Creation)

+ (Question *)questionForPrompt:(NSString *)prompt inManagedObjectContext:(NSManagedObjectContext *)context;

@end
