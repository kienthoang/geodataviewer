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
    //Create a new image
    Image *image=[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    image.imageData=imageData;
    
    return image;
}

@end
