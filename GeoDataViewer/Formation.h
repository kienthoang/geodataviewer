//
//  Formation.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bedding, Contact, Fault, Formation_Folder, JointSet;

@interface Formation : NSManagedObject

@property (nonatomic, retain) NSString * colorName;
@property (nonatomic, retain) NSString * formationName;
@property (nonatomic, retain) NSNumber * formationSortNumber;
@property (nonatomic, retain) NSSet *beddings;
@property (nonatomic, retain) NSSet *faults;
@property (nonatomic, retain) Formation_Folder *formationFolder;
@property (nonatomic, retain) NSSet *joinSets;
@property (nonatomic, retain) NSSet *lowerContacts;
@property (nonatomic, retain) NSSet *upperContacts;
@end

@interface Formation (CoreDataGeneratedAccessors)

- (void)addBeddingsObject:(Bedding *)value;
- (void)removeBeddingsObject:(Bedding *)value;
- (void)addBeddings:(NSSet *)values;
- (void)removeBeddings:(NSSet *)values;

- (void)addFaultsObject:(Fault *)value;
- (void)removeFaultsObject:(Fault *)value;
- (void)addFaults:(NSSet *)values;
- (void)removeFaults:(NSSet *)values;

- (void)addJoinSetsObject:(JointSet *)value;
- (void)removeJoinSetsObject:(JointSet *)value;
- (void)addJoinSets:(NSSet *)values;
- (void)removeJoinSets:(NSSet *)values;

- (void)addLowerContactsObject:(Contact *)value;
- (void)removeLowerContactsObject:(Contact *)value;
- (void)addLowerContacts:(NSSet *)values;
- (void)removeLowerContacts:(NSSet *)values;

- (void)addUpperContactsObject:(Contact *)value;
- (void)removeUpperContactsObject:(Contact *)value;
- (void)addUpperContacts:(NSSet *)values;
- (void)removeUpperContacts:(NSSet *)values;

@end
