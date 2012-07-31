//
//  Question+Seed.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Question.h"

@interface Question (Seed)

+ (void)seedDataInContext:(NSManagedObjectContext *)context;

@end
