//
//  PrototypeLoadingTableViewController.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSLoadingView.h>

@interface PrototypeLoadingTableViewController : UITableViewController

- (void)showLoadingScreen;
- (void)stopLoadingScreen;

@end
