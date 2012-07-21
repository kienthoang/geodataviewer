//
//  Record+Deletion.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record+Deletion.h"

@implementation Record (Deletion)

- (void)prepareForDeletion {
    //Delete the associated image if it only ahs one associated record
    Image *image=self.image;
    if (image.whoUses.count==1)
        [self.managedObjectContext deleteObject:image];
}

@end
