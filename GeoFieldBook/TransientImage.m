//
//  TransientImage.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientImage.h"

@interface TransientImage()

@property (nonatomic,strong) Image *managedImage;

@end

@implementation TransientImage

@synthesize imageData;
@synthesize imageHash;
@synthesize whoUses;

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

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert into the database
    self.managedImage=[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    self.managedImage.imageData=self.imageData;
    self.managedImage.imageHash=self.imageHash;
    self.managedImage.whoUses=self.whoUses;
}

@end
