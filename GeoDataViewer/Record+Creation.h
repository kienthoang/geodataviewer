//
//  Record+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"
#import "Folder.h"
#import "Image+Creation.h"

#import "Record+Types.h"
#import "Record+DictionaryKeys.h"

#import "Formation+Creation.h"

@interface Record (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
