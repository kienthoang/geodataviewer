//
//  Group+Modification.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group+Modification.h"

#import "Folder.h"
#import "Answer.h"

@implementation Group (Modification)

-(void)setColorWithRed:(double)red withGreen:(double)green withBlue:(double)blue{
    self.redComponent = [NSNumber numberWithDouble:red];
    self.greenComponent = [NSNumber numberWithDouble:green];
    self.blueComponent = [NSNumber numberWithDouble:blue];
   }

- (void)removeAndDeleteAllFolders {
    for (Folder *folder in self.folders)
        [self.managedObjectContext deleteObject:folder];
}

- (void)removeAndDeleteAllStudentResponses {
    for (Answer *response in self.responses)
        [self.managedObjectContext deleteObject:response];
}

@end
