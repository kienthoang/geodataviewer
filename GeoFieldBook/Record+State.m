//
//  Record+State.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+State.h"

@implementation Record (State)

@dynamic recordState;

- (int)recordState {
    return self.state.intValue;
}

- (void)setRecordState:(int)recordState {
    self.state=[NSNumber numberWithInt:recordState];
}

@end
