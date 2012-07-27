//
//  Contact+Formation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Contact+Formation.h"
#import "SettingManager.h"

@implementation Contact (Formation)

- (Formation *)formation
{
    NSString *defaultContactFormation=[SettingManager standardSettingManager].defaultContactFormation;
    return [defaultContactFormation isEqualToString:@"Upper Formation"] ? self.upperFormation : self.lowerFormation;
}

@end
