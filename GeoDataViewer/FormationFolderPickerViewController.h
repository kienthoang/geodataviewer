//
//  FormationFolderPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class FormationFolderPickerViewController;

@protocol FormationFolderPickerDelegate <NSObject>

- (void)formationFolderPickerViewController:(FormationFolderPickerViewController *)sender 
       userDidSelectFormationFolderWithName:(NSString *)folderName;

@end

@interface FormationFolderPickerViewController : PickerViewController

@property (nonatomic,strong) UIManagedDocument *database;
@property (nonatomic,strong) id <FormationFolderPickerDelegate> delegate;

#define FORMATION_FOLDER_PICKER_BLANK_OPTION @"None"

@end
