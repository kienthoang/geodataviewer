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

#pragma mark - View Controller Lifecycles

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType == UITableViewCellAccessoryNone)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if(cell.accessoryType == UITableViewCellAccessoryCheckmark && cell.isSelected)
        cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
