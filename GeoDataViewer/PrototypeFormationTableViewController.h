//
//  PrototypeFormationTableViewController.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "GeoDatabaseManager.h"
#import "Formation_Folder.h"
#import "Formation.h"

@interface PrototypeFormationTableViewController : CoreDataTableViewController

- (void)setupFetchedResultsController;

@property (nonatomic,strong) Formation_Folder *formationFolder;
@property (nonatomic,strong) UIManagedDocument *database;

- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message;

@end