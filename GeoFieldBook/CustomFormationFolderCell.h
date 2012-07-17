//
//  CustomFormationFolderCell.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/17/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import "Formation_Folder.h"

@class CustomFormationFolderCell;

@protocol CustomFormationFolderCellDelegate

- (void)folderCell:(CustomFormationFolderCell *)sender userDidSelectDidCheckBoxForRecord:(Formation_Folder *)folder;
- (void)folderCell:(CustomFormationFolderCell *)sender userDidDeselectDidCheckBoxForRecord:(Formation_Folder *)folder;

@end

@interface CustomFormationFolderCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subtitle;
@property (nonatomic,weak) IBOutlet UIImageView *checkBox;
@property (nonatomic,strong) Formation_Folder *folder;

@property (nonatomic,weak) id <CustomFormationFolderCellDelegate> delegate;

- (void)hideCheckBoxAnimated:(BOOL)animated;
- (void)showCheckBoxAnimated:(BOOL)animated;

@end
