//
//  TransientFormation.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientFormation_Folder.h"
#import "TransientManagedObject.h"

@interface TransientFormation : TransientManagedObject
@property (nonatomic, retain) NSString * formationName;
@property (nonatomic, retain) NSNumber * formationSortNumber;
@property (nonatomic, retain) NSSet *beddings;
@property (nonatomic, retain) NSSet *faults;
@property (nonatomic, retain) TransientFormation_Folder *formationFolder;
@property (nonatomic, retain) NSSet *joinSets;
@property (nonatomic, retain) NSSet *lowerContacts;
@property (nonatomic, retain) NSSet *upperContacts;
@end
