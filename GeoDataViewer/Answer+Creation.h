//
//  Answer+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer.h"

#import "Answer+DictionaryKeys.h"

#import "Question+Creation.h"

@interface Answer (Creation)

+ (Answer *)responseForInfo:(NSDictionary *)responseInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
