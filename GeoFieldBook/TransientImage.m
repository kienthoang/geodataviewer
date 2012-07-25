//
//  TransientImage.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientImage.h"
#import <CommonCrypto/CommonDigest.h>

@interface TransientImage()

@property (nonatomic,strong) Image *managedImage;

@end

@implementation TransientImage

@synthesize imageData=_imageData;

@synthesize managedImage=_managedImage;

- (Image *)saveImageToManagedObjectContext:(NSManagedObjectContext *)context 
                                completion:(completion_handler_t)completionHandler
{
    //Save to database
    [self saveToManagedObjectContext:context completion:completionHandler];
    return self.managedImage;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert into the database
    self.managedImage=[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    self.managedImage.imageData=self.imageData;
}

@end
