//
//  ExportFormationTableViewController.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrototypeFormationTableViewController.h"
#import "UIDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

@interface ExportFormationTableViewController : PrototypeFormationTableViewController <UIDoubleTableViewControllerChildren>

@property (nonatomic,strong) NSSet *selectedFormations;

@end