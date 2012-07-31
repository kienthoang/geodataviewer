//
//  Record+Creation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"

@interface Record (Creation)

+ (Record *)recordForRecordType:(NSString *)recordType 
                  andFolderName:(NSString *)folderName 
         inManagedObjectContext:(NSManagedObjectContext *)context;

@end
