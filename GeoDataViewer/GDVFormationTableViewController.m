//
//  GDVFormationTableViewController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFormationTableViewController.h"

#import "CustomFormationCell.h"

@interface GDVFormationTableViewController ()

@end

@implementation GDVFormationTableViewController

@synthesize formationFolder=_formationFolder;
@synthesize formations=_formations;

- (void)setFormations:(NSArray *)formations {
    if (formations) {
        _formations=formations;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Relaod table view
        [self.tableView reloadData];
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

#pragma mark - Table view data source

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

@end
