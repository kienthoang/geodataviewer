//
//  GeoFieldBookController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/7/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeoFieldBookController : UIViewController

@property (nonatomic,strong) UIPopoverController *popoverViewController;
@property (nonatomic,strong) UIViewController *viewGroupController;

#define IMPORT_EXPORT_ACTION_SHEET_TITLE @"Import/Export"
#define RECORD_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Record Import TVC"
#define FORMATION_IMPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Formation Import TVC"
#define RECORD_EXPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Record Export TVC"
#define FORMATION_EXPORT_TABLE_VIEW_CONTROLLER_IDENTIFIER @"Formation Export TVC"

@property (nonatomic,weak) UIActivityIndicatorView *importExportSpinner;
@property (nonatomic,weak) UIBarButtonItem *importExportSpinnerBarButtonItem;

#define AUTOSAVE_ALERT_TITLE @"Autosave"
#define CANCEL_ALERT_TITLE @"Stop Editing"

@end
