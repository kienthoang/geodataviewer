//
//  GDVFormationViewController.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Formation+DictionaryKeys.h"

@class GDVFormationViewController;

@protocol GDVFormationViewControllerDelegate <NSObject>

- (void)formationViewController:(GDVFormationViewController *)sender 
        didAskToModifyFormation:(Formation *)formation 
             andObtainedNewInfo:(NSDictionary *)formationInfo;

@end

@interface GDVFormationViewController : UIViewController

@property (nonatomic,weak) id <GDVFormationViewControllerDelegate> delegate;
@property (nonatomic,strong) Formation *formation;
@property (nonatomic,strong) NSString *formationName;
@property (nonatomic,strong) UIColor *formationColor;
@property (nonatomic,strong) NSString *formationColorName;

@end
