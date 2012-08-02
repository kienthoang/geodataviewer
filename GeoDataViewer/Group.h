//
//  Group.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Folder;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfMembers;
@property (nonatomic, retain) NSNumber * faulty;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *responses;
@property (nonatomic, retain) NSSet *folders;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addResponsesObject:(Answer *)value;
- (void)removeResponsesObject:(Answer *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
