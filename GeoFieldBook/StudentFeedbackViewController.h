//
//  StudentFeedbackViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CoreDataTableViewController.h"

@interface StudentFeedbackViewController : CoreDataTableViewController

@property (nonatomic,strong) UIManagedDocument *database;

@end
