//
//  TransientFormation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "TransientFormation.h"

#import "SettingManager.h"

@interface TransientFormation()

@property (nonatomic,strong) Formation *managedFormation;

@end

@implementation TransientFormation

@synthesize formationName=_formationName;
@synthesize formationSortNumber=_formationSortNumber;
@synthesize formationFolder=_formationFolder;
@synthesize formationColor = _formationColor;
@synthesize colorName = _colorName;

@synthesize managedFormation=_managedFormation;

- (Formation *)saveFormationToManagedObjectContext:(NSManagedObjectContext *)context {
    if (self.formationName.length && ![self.formationName isEqualToString:@"(null)"]) {
        //Query for the formation with the same name before saving
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",self.formationName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        NSArray *results=[context executeFetchRequest:request error:NULL];
        
        if (results.count)
            return results.lastObject;
        
        //Save formation
        Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
        formation.formationName=self.formationName;
        formation.formationSortNumber=self.formationSortNumber;
        formation.formationFolder=[TransientFormation_Folder defaultFolderManagedObjectContext:context];
        formation.colorName=self.colorName;
        
        return formation;
    }
    
    return nil;
}

- (void)saveToManagedObjectContext:(NSManagedObjectContext *)context completion:(completion_handler_t)completionHandler
{
    //Insert a new formation entity to the database
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=self.formationName;
    formation.formationSortNumber=self.formationSortNumber;
    formation.formationFolder=[self.formationFolder saveFormationFolderToManagedObjectContext:context completion:completionHandler];
    
    //Set the color name
    formation.colorName=self.colorName;
    
    self.managedFormation=formation;
}

@end
