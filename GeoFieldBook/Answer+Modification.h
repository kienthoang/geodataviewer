//
//  Answer+Modification.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer.h"
#import "Answer+DictionaryKeys.h"

#import <CoreLocation/CoreLocation.h>

@interface Answer (Modification)

- (void)updateWithInfo:(NSDictionary *)answerInfo;

@end
