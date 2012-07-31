//
//  MainSettingsTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsSplitViewController.h"

@class MainSettingsTableViewController;

@protocol MainSettingsTableViewControllerDelegate

- (void)mainSettingsTVC:(MainSettingsTableViewController *)sender userDidSelectSettingPaneWithTitle:(NSString *)paneTitle;
- (void)userDidPressCancel:(MainSettingsTableViewController *)sender;

@end

@interface MainSettingsTableViewController : UITableViewController <CustomSplitViewControllerChildren>

@property (nonatomic,weak) id <MainSettingsTableViewControllerDelegate> delegate;

@end
