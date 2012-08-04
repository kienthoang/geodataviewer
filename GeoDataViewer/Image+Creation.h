//
//  Image+Creation.h
//  GeoFieldBook
//
//  Created by excel2011 on 6/28/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Image.h"

@interface Image (Creation)

+ (Image *)imageWithBinaryData:(NSData *)imageData inManagedObjectContext:(NSManagedObjectContext *)context;

@end
