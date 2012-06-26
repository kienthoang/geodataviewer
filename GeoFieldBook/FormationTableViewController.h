//
//  FormationTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface FormationTableViewController : CoreDataTableViewController

@property (nonatomic,strong) NSString *formationFolder;  //The name of the folder the formations are in
@property (nonatomic,strong) UIManagedDocument *database;

@end
