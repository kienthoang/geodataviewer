//
//  GDVStudentResponseTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"

#import "Group.h"
#import "Answer.h"

@interface GDVStudentResponseTVC : PrototypeLoadingTableViewController

@property (nonatomic,strong) Group *studentGroup;
@property (nonatomic,strong) NSArray *studentResponses;

@end
