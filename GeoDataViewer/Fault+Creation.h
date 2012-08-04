//
//  Fault+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Fault.h"

#import "Record+Creation.m"

@interface Fault (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inFolder:(Folder *)folder;

@end
