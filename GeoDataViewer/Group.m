//
//  Group.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/6/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Group.h"
#import "Answer.h"
#import "Folder.h"


@implementation Group

@dynamic faulty;
@dynamic identifier;
@dynamic name;
@dynamic numberOfMembers;
@dynamic redComponent;
@dynamic blueComponent;
@dynamic greenComponent;
@dynamic folders;
@dynamic responses;

-(void)setColorWithRed:(NSNumber *)red withGreen:(NSNumber *)green withBlue:(NSNumber *)blue {
    self.redComponent = red;
    self.greenComponent = green;
    self.blueComponent = blue;
}

@end
