//
//  TransientFormation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFormation.h"

@implementation TransientFormation
@synthesize formationName=_formationName;
@synthesize formationSortNumber=_formationSortNumber;
@synthesize formationFolder=_formationFolder;

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=self.formationName;
    formation.formationSortNumber=self.formationSortNumber;
    formation.formationFolder=[self.formationFolder saveFormationFolderToManagedObjectContext:context completion:completionHandler];
}

@end
