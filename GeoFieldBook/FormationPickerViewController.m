//
//  FormationPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationPickerViewController.h"
#import "Formation.h"

@interface FormationPickerViewController() <UIPickerViewDelegate>

- (void)synchronizeWithFormationDatabase;

@end

@implementation FormationPickerViewController

@synthesize database=_database;
@synthesize folderName=_folderName;
@synthesize pickerName=_pickerName;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
        
    //Synchronize with the database
    [self synchronizeWithFormationDatabase];
}

- (void)setFolderName:(NSString *)folderName {
    _folderName=folderName;
    
    //Synchronize with the database
    [self synchronizeWithFormationDatabase];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    //Notify the user of user selection if user did not select the blank option; otherwise pass an empty string to the delegate
    NSString *userSelection=[[self userSelection] isEqualToString:FORMATION_PICKER_BLANK_OPTION] ? @"" : [self userSelection];
    [self.delegate formationPickerViewController:self userDidSelectFormationWithName:userSelection];
}

- (NSArray *)userSelectedComponentsFromSelection:(NSString *)previousSelection {
    return [NSArray arrayWithObject:previousSelection];
}

#pragma mark - UIPickerViewControllerDelegate

- (void)pickerView:(UIPickerView *)pickerView 
      didSelectRow:(NSInteger)row 
       inComponent:(NSInteger)component
{
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - Picker View State Initialization

- (NSArray *)pickerViewComponentMatrixFromFormations:(NSArray *)formations {
    NSMutableArray *formationNames=[NSMutableArray arrayWithCapacity:[formations count]];
    //Add blank option
    [formationNames addObject:FORMATION_PICKER_BLANK_OPTION];
    
    //Add the names of the formations
    for (Formation *formation in formations)
        [formationNames addObject:formation.formationName];
    
    //Component matrix of size 1 (the only element is the array of formation names)
    return [NSArray arrayWithObject:[formationNames copy]];
}

- (void)fetchFormationFromDatabase {
    //Fetch formation entities from the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation"];
    request.predicate=[NSPredicate predicateWithFormat:@"formationFolder.folderName=%@",self.folderName];
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