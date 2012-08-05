//
//  GDVRecordTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVRecordTVC.h"

#import "CustomRecordCell.h"

@interface GDVRecordTVC ()

@end

@implementation GDVRecordTVC

@synthesize folder=_folder;
@synthesize records=_records;

#pragma mark - Getters and Setters

- (void)setRecords:(NSArray *)records {
    if (records) {
        _records=records;
        
        //Stop the loading screen
        [self stopLoadingScreen];
        
        //Sort records
        _records=[_records sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
        
        //Relaod table view
        [self.tableView reloadData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Show loading screen while asking for data
    if (!self.records)
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
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Record Cell";
    CustomRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Record *record=[self.records objectAtIndex:indexPath.row];
    cell.record=record;
    
    return cell;
}

@end
