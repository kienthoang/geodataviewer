//
//  Contact+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Contact.h"
#import "Record+Creation.h"

@interface Contact (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
