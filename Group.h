//
//  Group.h
//  GeoDataViewer
//
//  Created by excel 2011 on 8/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Folder;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * blueComponent;
@property (nonatomic, retain) NSNumber * faulty;
@property (nonatomic, retain) NSNumber * greenComponent;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfMembers;
@property (nonatomic, retain) NSNumber * redComponent;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSSet *responses;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addResponsesObject:(Answer *)value;
- (void)removeResponsesObject:(Answer *)value;
- (void)addResponses:(NSSet *)values;
- (void)removeResponses:(NSSet *)values;

@end