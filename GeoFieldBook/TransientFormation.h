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
@property (nonatomic, strong) NSString * formationName;
@property (nonatomic, strong) NSString *formationFolderName;
@property (nonatomic, strong) NSNumber * formationSortNumber;
@property (nonatomic, strong) NSSet *beddings;
@property (nonatomic, strong) NSSet *faults;
@property (nonatomic, strong) TransientFormation_Folder *formationFolder;
@property (nonatomic, strong) NSSet *joinSets;
@property (nonatomic, strong) NSSet *lowerContacts;
@property (nonatomic, strong) NSSet *upperContacts;
@end
