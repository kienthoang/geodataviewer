//
//  Formation_Folder+Modification.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder+Modification.h"

#import "Formation.h"

@implementation Formation_Folder (Modification)

- (void)removeAndDeleteAllFormations {
    for (Formation *formation in self.formations)
        [self.managedObjectContext deleteObject:formation];
}

@end
