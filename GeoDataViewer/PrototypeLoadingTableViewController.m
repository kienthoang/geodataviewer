//
//  PrototypeLoadingTableViewController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeLoadingTableViewController.h"

@interface PrototypeLoadingTableViewController ()

@property (nonatomic,weak) SSLoadingView *loadingView;

@end

@implementation PrototypeLoadingTableViewController

@synthesize loadingView=_loadingView;

- (void)showLoadingScreen {
    if (!self.loadingView) {
        CGSize size = self.view.frame.size;
        
        SSLoadingView *loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        [self.view addSubview:loadingView];
        self.loadingView=loadingView;
    }
}

- (void)stopLoadingScreen {
    if (self.loadingView)
        [self.loadingView removeFromSuperview];
}

@end
