//
//  GDVController.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDVResourceManager.h"

#import "GDVStudentGroupTVC.h"
#import "GDVFolderTVC.h"
#import "GDVRecordTVC.h"

#import "GDVFeedbackTVC.h"

#import "GDVFormationFolderTVC.h"
#import "GDVFormationTableViewController.h"

#import "ImportTableViewController.h"

#import "RecordMapViewController.h"

@interface GDVController : UIViewController

#pragma mark - Model

@property (nonatomic,readonly) GDVResourceManager *resourceManager;

#pragma mark - Views

@property (nonatomic,strong) UINavigationController *recordList;
@property (nonatomic,strong) UINavigationController *feedbackList;
@property (nonatomic,weak) UIPopoverController *formationListPopover;

@property (nonatomic,strong) RecordMapViewController *mapViewController;

@end
