//
//  Group+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group.h"

#import "Group+DictionaryKeys.h"

@interface Group (Creation)

+ (Group *)studentGroupForInfo:(NSDictionary *)groupInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
