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

#define IMPORT_EXPORT_ACTION_SHEET_TITLE @"Import/Export"
#define RECORD_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Import Records"
#define FORMATION_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Import Formations"
#define STUDENT_RESPONSE_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Import Student Responses"

#pragma mark - Model

@property (nonatomic,readonly) GDVResourceManager *resourceManager;

#pragma mark - Views

@property (nonatomic,strong) UIPopoverController *recordList;
@property (nonatomic,strong) UIPopoverController *studentResponseList;
@property (nonatomic,weak) UIPopoverController *formationListPopover;

@property (nonatomic,strong) RecordMapViewController *mapViewController;

@end
