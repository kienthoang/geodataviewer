//
//  GDVFormationFolderTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"
#import "GDVFormationFolderTVCDelegate.h"

#import "Formation_Folder.h"

@interface GDVFormationFolderTVC : PrototypeLoadingTableViewController

@property (nonatomic,strong) NSArray *formationFolders;

@property (nonatomic,weak) id <GDVFormationFolderTVCDelegate> delegate;

@end
