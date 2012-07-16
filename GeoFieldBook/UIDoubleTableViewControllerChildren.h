//
//  UIDoubleTableViewControllerChildren.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIDoubleTableViewController;

@protocol UIDoubleTableViewControllerChildren <NSObject>

@property (nonatomic,weak) UIDoubleTableViewController *doubleTableViewController;

@end
