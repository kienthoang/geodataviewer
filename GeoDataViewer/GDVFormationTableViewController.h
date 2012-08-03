//
//  GDVFormationTableViewController.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"

#import "Formation_Folder.h"
#import "Formation.h"

@interface GDVFormationTableViewController : PrototypeLoadingTableViewController

@property (nonatomic,strong) Formation_Folder *formationFolder;
@property (nonatomic,strong) NSArray *formations;

@end
