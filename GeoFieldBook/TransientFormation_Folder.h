//
//  TransientFormation_Folder.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientManagedObject.h"

@interface TransientFormation_Folder : TransientManagedObject

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSSet *formations;
@property (nonatomic, retain) NSSet *folders;
@end
