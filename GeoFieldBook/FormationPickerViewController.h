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
@property (nonatomic,strong) Formation_Folder *formationFolder;    //The folder the formations showed in the picker view are in.

@property (nonatomic,strong) id <FormationPickerDelegate> delegate;

@end
