//
//  TransientImage.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransientImage : NSObject
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSData * imageHash;
@property (nonatomic, retain) NSSet *whoUses;
@end
