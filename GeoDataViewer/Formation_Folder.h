//
//  Formation_Folder.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder, Formation;

@interface Formation_Folder : NSManagedObject

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSNumber * faulty;
@property (nonatomic, retain) NSSet *folders;
@property (nonatomic, retain) NSSet *formations;
@end

@interface Formation_Folder (CoreDataGeneratedAccessors)

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

- (void)addFormationsObject:(Formation *)value;
- (void)removeFormationsObject:(Formation *)value;
- (void)addFormations:(NSSet *)values;
- (void)removeFormations:(NSSet *)values;

@end
