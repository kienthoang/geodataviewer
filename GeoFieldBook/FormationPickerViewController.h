//
//  FormationPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"
#import "Formation_Folder.h"
#import <CoreData/CoreData.h>

@class FormationPickerViewController;

@protocol FormationPickerDelegate <NSObject>

- (void)formationPickerViewController:(FormationPickerViewController *)sender 
       userDidSelectFormationWithName:(NSString *)formationName;

@end

@interface FormationPickerViewController : PickerViewController

@property (nonatomic,strong) UIManagedDocument *database;
@property (nonatomic,strong) NSString *folderName;    //The name of the folder the formations showed in the picker view are in.
@property (nonatomic,strong) NSString *pickerName;   //The name of the picker, to distinguish between formation, lower formation, and upper formation pickers

@property (nonatomic,strong) id <FormationPickerDelegate> delegate;

#define FORMATION_PICKER_BLANK_OPTION @"<None>"

@end
