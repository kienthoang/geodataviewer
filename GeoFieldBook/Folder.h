//
//  Folder.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Formation_Folder, Record;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSNumber * folderID;
@property (nonatomic, retain) NSSet *records;
@property (nonatomic, retain) Formation_Folder *formationFolder;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addRecordsObject:(Record *)value;
- (void)removeRecordsObject:(Record *)value;
- (void)addRecords:(NSSet *)values;
- (void)removeRecords:(NSSet *)values;

@end
