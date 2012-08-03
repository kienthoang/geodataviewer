//
//  TransientGroup.h
//  GeoDataViewer
//
//  Created by excel 2011 on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransientGroup : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * numberOfMembers;
@property (nonatomic, strong) NSNumber * faulty;
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSSet *responses;
@property (nonatomic, strong) NSSet *folders;

@end
