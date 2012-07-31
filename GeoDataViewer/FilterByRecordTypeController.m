//
//  FilterByRecordTypeController.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FilterByRecordTypeController.h"
#import <Foundation/Foundation.h>



@interface FilterByRecordTypeController ()

@end

@implementation FilterByRecordTypeController

@synthesize allRecordTypes=_allRecordTypes;
@synthesize selectedRecordTypes=_selectedRecordTypes;
@synthesize delegate = _delegate;

#pragma mark - View Controller Lifecycle
          
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allRecordTypes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Record Types";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CELL_IDENTIFIER=@"Record Type Cell";
    
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (!cell)
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    
    //Set up cell
    cell.textLabel.text=[self.allRecordTypes objectAtIndex:indexPath.row];
    
    //Toggle checkmark
    if ([self.selectedRecordTypes containsObject:cell.textLabel.text])
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType=UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Toggle checkmark
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType=cell.accessoryType==UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    
    //Notify the delegate
    if (cell.accessoryType==UITableViewCellAccessoryCheckmark)
        [self.delegate filterByTypeController:self userDidSelectRecordType:cell.textLabel.text];
    else 
        [self.delegate filterByTypeController:self userDidDeselectRecordType:cell.textLabel.text];
}

@end
