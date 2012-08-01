//
//  TransientProject.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientManagedObject.h"
#import "TransientFormation_Folder.h"

#import "Folder.h"

@interface TransientProject : TransientManagedObject

@property (nonatomic, strong) NSNumber * folderID;
@property (nonatomic, strong) NSString * folderName;
@property (nonatomic, strong) NSString * folderDescription;
@property (nonatomic, strong) TransientFormation_Folder *formationFolder;
@property (nonatomic, strong) NSArray *records;

- (Folder *)saveFolderToManagedObjectContext:(NSManagedObjectContext *)context;

@end
