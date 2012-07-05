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
@property (nonatomic, strong) NSMutableSet *selectedRecordTypes;
@end

@implementation FilterByRecordTypeController
@synthesize selectedRecordTypes=_selectedRecordTypes;
@synthesize delegate = _delegate;

#pragma mark - View Controller Lifecycles

- (void) viewWillDisappear:(BOOL)animated {
    //call the delegate's method that will show only the record types in the set    
    if(self.delegate){
        [self.delegate updateMapViewByShowing:self.selectedRecordTypes];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //initialize the set if not initialized
    if(!self.selectedRecordTypes)
        self.selectedRecordTypes = [[NSMutableSet alloc] init];
    
    //toggle and keep a track of the selected record types
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedRecordTypes addObject:cell.textLabel.text];
    }
    else if(cell.accessoryType == UITableViewCellAccessoryCheckmark && cell.isSelected){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedRecordTypes removeObject:cell.textLabel.text];
    }
}



@end
