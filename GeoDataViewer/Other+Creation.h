//
//  Other+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Other.h"
#import "Record+Creation.h"

@interface Other (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
