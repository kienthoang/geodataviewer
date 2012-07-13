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
@synthesize imageHash=_imageHash;

@synthesize managedImage=_managedImage;

- (Image *)saveImageToManagedObjectContext:(NSManagedObjectContext *)context 
                                completion:(completion_handler_t)completionHandler
{
    //Query to see if the image is already in the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Image"];
    request.predicate=[NSPredicate predicateWithFormat:@"imageHash=%@",self.imageHash];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"imageHash" ascending:YES]];
    NSArray *results=[context executeFetchRequest:request error:NULL];
    if (results.count)
        return [results lastObject];
    
    //Save to database otherwise
    [self saveToManagedObjectContext:context completion:completionHandler];
    return self.managedImage;
}

- (void)setImageData:(NSData *)imageData {
    //Get the hash data
    __weak TransientImage *weakSelf=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData *imageHashKey=[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(imageData.bytes,imageData.length,imageHashKey.mutableBytes);
        weakSelf.imageHash=imageHashKey;
    });
    
    _imageData=imageData;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert into the database
    self.managedImage=[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    self.managedImage.imageData=self.imageData;
    self.managedImage.imageHash=self.imageHash;
}

@end
