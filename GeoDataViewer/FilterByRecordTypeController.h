//
//  FilterByRecordTypeController.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterByRecordTypeController;

@protocol FilterRecordsByType

- (void)filterByTypeController:(FilterByRecordTypeController *)sender userDidSelectRecordType:(NSString *)recordType;
- (void)filterByTypeController:(FilterByRecordTypeController *)sender userDidDeselectRecordType:(NSString *)recordType;

@end

@interface FilterByRecordTypeController : UITableViewController

@property (nonatomic,strong) id <FilterRecordsByType> delegate;
@property (nonatomic,strong) NSArray *selectedRecordTypes;
@property (nonatomic,strong) NSArray *allRecordTypes;

@end
