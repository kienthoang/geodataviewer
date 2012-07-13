//
//  TransientImage.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientManagedObject.h"

#import "Image.h"

@interface TransientImage : TransientManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSData * imageHash;

- (Image *)saveImageToManagedObjectContext:(NSManagedObjectContext *)context 
                                completion:(completion_handler_t)completionHandler;

@end
