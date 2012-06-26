//
//  FormationFolderViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormationFolderViewController;

@protocol FormationFolderViewControllerDelegate <NSObject>

- (void)formationFolderViewController:(FormationFolderViewController *)sender 
      didObtainNewFormationFolderName:(NSString *)formationFolderName;

- (void)formationFolderViewController:(FormationFolderViewController *)sender 
         didAskToModifyFolderWithName:(NSString *)originalName 
                   andObtainedNewName:(NSString *)folderName;

@end

@interface FormationFolderViewController : UIViewController

@property (nonatomic,weak) id <FormationFolderViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString *folderName;

@end
