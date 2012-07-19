//
//  ExportFormationFolderTableViewController.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeFormationFolderTableViewController.h"
#import "ExportDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

#import "ExportFormationTableViewControllerDelegate.h"

@interface ExportFormationFolderTableViewController : PrototypeFormationFolderTableViewController <UIDoubleTableViewControllerChildren,ExportFormationTableViewControllerDelegate>

@property (nonatomic,strong) NSArray *selectedFormations;

@property (nonatomic,weak) id <ExportButtonOwner> exportButtonOwner;

@end
