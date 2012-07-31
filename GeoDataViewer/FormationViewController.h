//
//  FormationViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Formation+DictionaryKeys.h"

@class FormationViewController;

@protocol FormationViewControllerDelegate <NSObject>

- (void)formationViewController:(FormationViewController *)sender 
      didObtainNewFormationInfo:(NSDictionary *)formationInfo;

- (void)formationViewController:(FormationViewController *)sender 
        didAskToModifyFormation:(Formation *)formation 
             andObtainedNewInfo:(NSDictionary *)formationInfo;

@end

@interface FormationViewController : UIViewController

@property (nonatomic,weak) id <FormationViewControllerDelegate> delegate;
@property (nonatomic,strong) Formation *formation;
@property (nonatomic,strong) NSString *formationName;
@property (nonatomic,strong) UIColor *formationColor;
@property (nonatomic,strong) NSString *formationColorName;

@end
