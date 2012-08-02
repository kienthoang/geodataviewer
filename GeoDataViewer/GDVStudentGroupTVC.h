//
//  GDVStudentGroupTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSLoadingView.h>

#import "Group.h"

@interface GDVStudentGroupTVC : UITableViewController

- (void)showLoadingScreen;
- (void)stopLoadingScreen;

@property (nonatomic,strong) NSArray *studentGroups;

@end
