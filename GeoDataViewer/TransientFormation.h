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

#import "Formation.h"

@interface TransientFormation : TransientManagedObject

@property (nonatomic, strong) NSString * formationName;
@property (nonatomic, strong) NSNumber * formationSortNumber;
@property (nonatomic, strong) TransientFormation_Folder *formationFolder;
@property (nonatomic, strong) UIColor *formationColor;
@property (nonatomic, strong) NSString *colorName;

- (Formation *)saveFormationToManagedObjectContext:(NSManagedObjectContext *)context;

@end
