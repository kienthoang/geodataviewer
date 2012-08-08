//
//  Formation+Creation.m

//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation+Creation.h"
#import "Formation+DictionaryKeys.h"

#import "TextInputFilter.h"

@implementation Formation (Creation)

+ (Formation *)formationForInfo:(NSDictionary *)formationInfo 
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Get the formation name and color from the info dictionary
    NSString *formationName=[formationInfo objectForKey:GeoFormationName];
    formationName=[TextInputFilter filterDatabaseInputText:formationName];
    NSString *color=[formationInfo objectForKey:GeoFormationColorName];

    //Create a new formation
    Formation *formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
    formation.formationName=formationName;
    formation.color=color;
    formation.formationSortNumber = [formationInfo objectForKey:GeoFormationSortIndex];
        
    return formation;
}

+ (Formation *)formationWithName:(NSString *)formationName inManagedObjectContext:(NSManagedObjectContext *)context 
{    
    Formation *formation=nil;
            
    if (formationName.length) {
        //Look for a formation with the given name in the database
        NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"Formation"];
        request.predicate=[NSPredicate predicateWithFormat:@"formationName=%@",formationName];
        request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
        NSArray *results=[context executeFetchRequest:request error:NULL];
        if (results.count)
            formation=results.lastObject;
        else {
            //If no such formation exists, create one
            formation=[NSEntityDescription insertNewObjectForEntityForName:@"Formation" inManagedObjectContext:context];
            formation.formationName=formationName;
            formation.formationFolder=[Formation_Folder defaultFormationFolderInManagedObjectContext:context];
        }        
    }
#warning Set default color for imported formations
        
    return formation;
}

@end
