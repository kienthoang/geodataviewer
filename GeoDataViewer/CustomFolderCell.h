//
//  CustomFolderCell.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import "Folder.h"

@class CustomFolderCell;

@protocol CustomFolderCellDelegate

- (void)folderCell:(CustomFolderCell *)sender userDidSelectDidCheckBoxForFolder:(Folder *)folder;
- (void)folderCell:(CustomFolderCell *)sender userDidDeselectDidCheckBoxForFolder:(Folder *)folder;

@end

@interface CustomFolderCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subtitle;
@property (nonatomic,weak) IBOutlet UIImageView *checkBox;
@property (nonatomic,strong) Folder *folder;

@property (nonatomic,weak) id <CustomFolderCellDelegate> delegate;

- (void)hideCheckBoxAnimated:(BOOL)animated;
- (void)showCheckBoxAnimated:(BOOL)animated;

@end
