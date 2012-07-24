//
//  Record+State.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"

@interface Record (State)

typedef enum RecordState {RecordStateNew,RecordStateUpdated} RecordState;

@property (nonatomic) int recordState;

@end
