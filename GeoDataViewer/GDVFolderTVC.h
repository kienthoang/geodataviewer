//
//  GDVFolderTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSLoadingView.h>

#import "Group.h"
#import "Folder.h"

@interface GDVFolderTVC : UITableViewController

@property (nonatomic,strong) Group *studentGroup;
@property (nonatomic,strong) NSArray *folders;

- (void)showLoadingScreen;
- (void)stopLoadingScreen;

@end
