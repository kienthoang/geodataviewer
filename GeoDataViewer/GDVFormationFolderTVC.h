//
//  GDVFormationFolderTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSLoadingView.h>

@interface GDVFormationFolderTVC : UITableViewController

- (void)showLoadingScreen;

@property (nonatomic,strong) NSArray *formationFolders;

@end
