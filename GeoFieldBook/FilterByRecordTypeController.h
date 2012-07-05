//
//  FilterByRecordTypeController.h
//  GeoFieldBook
//
//  Created by excel 2011 on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterRecordsByType <NSObject>

-(void) updateMapViewByShowing:(NSMutableSet *)recordTypesSelected;

@end

@interface FilterByRecordTypeController : UITableViewController
@property (nonatomic, strong) id<FilterRecordsByType> delegate;
@property (nonatomic, strong) NSMutableSet *selectedRecordTypes;
@end
