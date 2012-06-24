//
//  FormationPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationPickerViewController.h"
#import "Formation.h"

@interface FormationPickerViewController ()

- (void)synchronizeWithFormationDatabase;

@end

@implementation FormationPickerViewController

@synthesize database=_database;
@synthesize formationFolder=_formationFolder;

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
    
    //Synchronize with the database
    [self synchronizeWithFormationDatabase];
}

- (void)setFormationFolder:(Formation_Folder *)formationFolder {
    _formationFolder=formationFolder;
    
    //Synchronize with the database
    [self synchronizeWithFormationDatabase];
}

#pragma mark - Setup the picker view

- (NSArray *)pickerViewComponentMatrixFromFormations:(NSArray *)formations {
    //Create an array of the names of all formations
    NSMutableArray *formationNames=[NSMutableArray arrayWithCapacity:[formations count]];
    for (Formation *formation in formations)
        [formationNames addObject:formation.formationName];
    
    //Component matrix of size 1 (the only element is the array of formation names)
    return [NSArray arrayWithObject:[formationNames copy]];
}

- (void)fetchFormationFromDatabase {
    //Fetch formation entities from the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationFolder.folderName=%@",self.formationFolder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //Setup the component matrix (inherited from PickerViewController)
    self.componentMatrix=[self pickerViewComponentMatrixFromFormations:results];
}

- (void)synchronizeWithFormationDatabase {
    //Save the database if it has not been saved yet
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self.database.fileURL path]]) {
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                //Start fetching formations
                [self fetchFormationFromDatabase];
            }
        }];
    } 

    //If the database managed document is close, open it
    else if (self.database.documentState==UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success){
            //Fetch formations
            [self fetchFormationFromDatabase];
        }];
    } 

    //If the document is already open, just proceed
    else if (self.database.documentState==UIDocumentStateNormal) {
        //Fetch formations
        [self fetchFormationFromDatabase];
    }
}

#pragma mark - View Controller Life Cycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
