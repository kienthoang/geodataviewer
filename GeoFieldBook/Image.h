//
//  Image.h
//  GeoFieldBook
//
//  Created by excel2011 on 6/28/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Record;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSData * imageHash;
@property (nonatomic, retain) NSSet *whoUses;
@end

@interface Image (CoreDataGeneratedAccessors)

- (void)addWhoUsesObject:(Record *)value;
- (void)removeWhoUsesObject:(Record *)value;
- (void)addWhoUses:(NSSet *)values;
- (void)removeWhoUses:(NSSet *)values;

@end
