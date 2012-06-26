//
//  HomeViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISplitViewBarButtonPresenter.h"

@class HomeViewController;

@protocol HomeViewControllerDelegate <NSObject>

- (void)homeViewController:(HomeViewController *)sender userDidSelect:(NSString *)mode;

@end

@interface HomeViewController : UIViewController <UISplitViewBarButtonPresenter>

@property (nonatomic,weak) id <HomeViewControllerDelegate> delegate;

@end
