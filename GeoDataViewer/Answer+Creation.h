//
//  Answer+Creation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer.h"
#import "Answer+DictionaryKeys.h"

#import <CoreLocation/CoreLocation.h>

@interface Answer (Creation)

+ (Answer *)answerForInfo:(NSDictionary *)answerInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
