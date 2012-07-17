//
//  MNColorSelectionViewController.h
//  MindNodeTouch
//
//  Created by Markus Müller on 24.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MNColorSelectionViewControllerDelegate;

@interface MNColorSelectionViewController : UIViewController

+ (id)monoChromeSelectionViewController;
+ (id)modernColorsSelectionViewController;
+ (id)vintageColorsSelectionViewController;
+ (id)rainbowSelectionViewController;

- (id)initWithColors:(NSArray *)colors;

@property (nonatomic, assign) id <MNColorSelectionViewControllerDelegate> delegate;

@end


@protocol MNColorSelectionViewControllerDelegate <NSObject>

@required
- (UIColor *)colorSelectionControllerSelectedColor:(MNColorSelectionViewController *)controller;
- (void)colorSelectionController:(MNColorSelectionViewController *)controller didSelectedColor:(UIColor *)color;

@end
