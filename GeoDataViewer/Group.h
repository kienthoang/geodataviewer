//
//  Group.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder, Response_Record;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * blueComponent;
@property (nonatomic, retain) NSNumber * faulty;
@property (nonatomic, retain) NSNumber * greenComponent;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfMembers;
@property (nonatomic, retain) NSNumber * redComponent;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSSet *responseRecords;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addResponseRecordsObject:(Response_Record *)value;
- (void)removeResponseRecordsObject:(Response_Record *)value;
- (void)addResponseRecords:(NSSet *)values;
- (void)removeResponseRecords:(NSSet *)values;

@end
