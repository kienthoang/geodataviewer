//
//  ExportFormationTableViewController.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrototypeFormationTableViewController.h"
#import "ExportDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

#import "ExportFormationTableViewControllerDelegate.h"

@interface ExportFormationTableViewController : PrototypeFormationTableViewController <UIDoubleTableViewControllerChildren>

@property (nonatomic,strong) NSSet *selectedFormations;
@property (nonatomic,weak) id <ExportFormationTableViewControllerDelegate> delegate;

- (void)updateSelectedFormationsWith:(NSSet *)formations;

@end