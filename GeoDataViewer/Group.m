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

-(void)setColorWithRed:(NSString *)red withGreen:(NSString *)green withBlue:(NSString *)blue{
    NSLog(@"inside here with colors: %@ %@ %@", red, green, blue);
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.redComponent = [formatter numberFromString:red];
    self.greenComponent = [formatter numberFromString:green];
    self.blueComponent = [formatter numberFromString:blue];
     NSLog(@"inside here with colors: %@ %@ %@", self.redComponent, self.greenComponent, self.blueComponent);
}

@end
