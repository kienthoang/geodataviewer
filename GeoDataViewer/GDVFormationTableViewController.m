//
//  GDVFormationTableViewController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFormationTableViewController.h"
#import "GDVFormationViewController.h"

#import "CustomFormationCell.h"

#import "TextInputFilter.h"

@interface GDVFormationTableViewController () <GDVFormationViewControllerDelegate>

@end

@implementation GDVFormationTableViewController

@synthesize formationFolder=_formationFolder;
@synthesize formations=_formations;

@synthesize delegate=_delegate;

- (void)setFormations:(NSArray *)formations {
    if (formations) {
        _formations=formations;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Sort formations
        _formations=[_formations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"formationSortNumber" ascending:YES]]];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //If seguing to a formation view controller
    if ([segue.identifier isEqualToString:@"Update Formation"]) {
        //Set the delegate of the destination controller as self
        [segue.destinationViewController setDelegate:self];
        
        //If the sender is a UITableViewCell, set the formation of the destination controller as well
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell=sender;
            Formation *selectedFormation=[self.formations objectAtIndex:[self.tableView indexPathForCell:cell].row];
            [segue.destinationViewController setFormation:selectedFormation];
            [segue.destinationViewController setFormationColorName: selectedFormation.color];
        }
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.formations)
        [self showLoadingScreen];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Alert Generators

- (void)putUpAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (void)putUpDuplicateNameAlertWithName:(NSString *)duplicateName {
    NSString *message=[NSString stringWithFormat:@"A formation with the name '%@' already exists in this folder!",duplicateName];
    [self putUpAlertWithTitle:@"Name Duplicate" andMessage:message];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //Segue to the MoDalNewFolderViewController
    [self performSegueWithIdentifier:@"Update Formation" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.formations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Formation Cell";
    CustomFormationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Formation *formation=[self.formations objectAtIndex:indexPath.row];
    cell.formation=formation;
    
    return cell;
}

#pragma mark - Formation View Controller Delegate methods

- (void)formationViewController:(GDVFormationViewController *)sender 
        didAskToModifyFormation:(Formation *)formation 
             andObtainedNewInfo:(NSDictionary *)formationInfo
{
    //Modify the formation with the specified original name and if that returns YES (success), dismiss the modal
    if ([self.delegate gdvFormationTVC:self needsUpdateFormation:formation withInfo:formationInfo]) {
        //Dismiss the modal
        [self dismissModalViewControllerAnimated:YES];
        
        //Reload the corresponding cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.formations indexOfObject:formation] inSection:0];
        CustomFormationCell *cell=(CustomFormationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell reload];
    }
}


@end
