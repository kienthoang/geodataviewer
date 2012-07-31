//
//  FormationFolderPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationFolderPickerViewController.h"
#import "Formation_Folder.h"

@interface FormationFolderPickerViewController ()

- (void)synchronizeWithFormationFolderDatabase;

@end

@implementation FormationFolderPickerViewController

@synthesize database=_database;
@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setDatabase:(UIManagedDocument *)database {
    _database=database;
            
    //Synchronize with the database
    [self synchronizeWithFormationFolderDatabase];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    //Notify the user of user selection if user did not picked the blank option; otherqise pass empty string to the delegate
    NSString *userSelection=[[self userSelection] isEqualToString:FORMATION_FOLDER_PICKER_BLANK_OPTION] ? @"" : [self userSelection];
    [self.delegate formationFolderPickerViewController:self userDidSelectFormationFolderWithName:userSelection];
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

#pragma mark - Setup the picker view

- (NSArray *)pickerViewComponentMatrixFromFormationFolders:(NSArray *)formationFolders {
    NSMutableArray *folderNames=[NSMutableArray arrayWithCapacity:[formationFolders count]];
    //Add blank option
    [folderNames addObject:FORMATION_FOLDER_PICKER_BLANK_OPTION];
    
    //Add the names of all formation folders
    for (Formation_Folder *folder in formationFolders)
        [folderNames addObject:folder.folderName];
    
    //Component matrix of size 1 (the only element is the array of formation folder names)
    return [NSArray arrayWithObject:[folderNames copy]];
}

- (void)fetchFormationFolderFromDatabase {
    //Fetch formation folder entities from the database
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //Setup the component matrix (inherited from PickerViewController)
    self.componentMatrix=[self pickerViewComponentMatrixFromFormationFolders:results];
}

- (void)synchronizeWithFormationFolderDatabase {
    //Save the database if it has not been saved yet
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self.database.fileURL path]]) {
        [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                //Start fetching formations
                [self fetchFormationFolderFromDatabase];
            }
        }];
    } 
    
    //If the database managed document is close, open it
    else if (self.database.documentState==UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success){
            //Fetch formations
            [self fetchFormationFolderFromDatabase];
        }];
    } 
    
    //If the document is already open, just proceed
    else if (self.database.documentState==UIDocumentStateNormal) {
        //Fetch formation folders
        [self fetchFormationFolderFromDatabase];
    }
}


#pragma mark - View Controller Lifecycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
