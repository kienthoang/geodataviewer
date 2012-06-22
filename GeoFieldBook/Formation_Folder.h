//
//  Formation_Folder.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder, Formation;

@interface Formation_Folder : NSManagedObject

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSSet *formations;
@property (nonatomic, retain) NSSet *folders;
@end

@interface Formation_Folder (CoreDataGeneratedAccessors)

- (void)addFormationsObject:(Formation *)value;
- (void)removeFormationsObject:(Formation *)value;
- (void)addFormations:(NSSet *)values;
- (void)removeFormations:(NSSet *)values;

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
