//
//  Image+Creation.m
//  GeoFieldBook
//
//  Created by excel2011 on 6/28/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Image+Creation.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Image (Creation)

+ (Image *)imageWithBinaryData:(NSData *)imageData inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableData *imageHashKey=[NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(imageData.bytes,imageData.length,imageHashKey.mutableBytes);
    
    //Query the database for any existing image with the same hash key
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Image"];
    request.predicate=[NSPredicate predicateWithFormat:@"imageHash=%@",imageHashKey];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"imageHash" ascending:YES]];
    NSArray *images=[context executeFetchRequest:request error:NULL];
    
    Image *image=nil;
    if ([images count]) 
        image=[images lastObject];
    else {
        image=[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
        image.imageData=imageData;
        image.imageHash=imageHashKey;
    }
    
    return image;
}

@end
