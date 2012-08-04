//
//  Group+Creation.h
//  GeoDataViewer
//
//  Created by excel 2011 on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group.h"

@interface Group (Creation)

+ (Group *)groupWithGroupInfo:(NSDictionary *)info
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
