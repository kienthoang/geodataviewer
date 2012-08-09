//
//  GDVStudentGroupTVC.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PrototypeLoadingTableViewController.h"
#import "GDVStudentGroupTVCDelegate.h"

#import "Group.h"
#import "Group+Modification.h"

@interface GDVStudentGroupTVC : PrototypeLoadingTableViewController


#define RECORD_LIST_STUDENT_GROUP_IDENTIFIER @"Record List Student Group"
#define RESPONSE_LIST_STUDENT_GROUP_IDENTIFIER @"Response List Student Group"

@property (nonatomic,strong) NSArray *studentGroups;
@property (strong, nonatomic) NSArray *toBeDeletedGroups;

@property (nonatomic,weak) id <GDVStudentGroupTVCDelegate> delegate;

@property (nonatomic,strong) NSString *identifier;

#pragma mark - Buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectNoneButton;

#pragma mark - Public Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender;
- (IBAction)deletePressed:(UIBarButtonItem *)sender;
- (IBAction)selectAll:(UIBarButtonItem *)sender;
- (IBAction)selectNone:(UIBarButtonItem *)sender;

@end
