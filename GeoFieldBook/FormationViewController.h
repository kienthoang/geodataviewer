//
//  FormationViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormationViewController;

@protocol FormationViewControllerDelegate <NSObject>

- (void)formationViewController:(FormationViewController *)sender 
      didObtainNewFormationName:(NSString *)formationName;

- (void)formationViewController:(FormationViewController *)sender 
didAskToModifyFormationWithName:(NSString *)originalName 
             andObtainedNewName:(NSString *)folderName;

@end

@interface FormationViewController : UIViewController

@property (nonatomic,weak) id <FormationViewControllerDelegate> delegate;
@property (nonatomic,strong) NSString *formationName;

@end
