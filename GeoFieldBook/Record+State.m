//
//  Record+State.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+State.h"

#import <objc/runtime.h>

@implementation Record (State)

@dynamic state;

static char const * const StateTagkey="State";

- (void)setState:(RecordState)state {
    NSNumber *stateObj=[NSNumber numberWithInt:state];
    objc_setAssociatedObject(self, StateTagkey, stateObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RecordState)isNewlyCreated {
    NSNumber *state=objc_getAssociatedObject(self, StateTagkey);
    return state.intValue;
}

@end
