//
//  GeoFilter.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeoFilter : NSObject

- (void)userDidSelectRecordType:(NSString *)recordType;   //Add user's selection
- (void)userDidDeselectRecordType:(NSString *)recordType;

- (void)userDidSelectFolderWithName:(NSString *)folderName;   //Add user's selection
- (void)userDidDeselectFolderWithName:(NSString *)folderName;

- (void)changeFolderName:(NSString *)originalName toFolderName:(NSString *)newName;

- (NSArray *)filterRecordCollectionByRecordType:(NSArray *)records;    //Filters the specified array of records and returns the results
- (NSArray *)filterRecordCollectionByFolder:(NSArray *)records;    //Filters the specified array of records and returns the results

@property (nonatomic,readonly) NSArray *allRecordTypes;
@property (nonatomic,strong) NSArray *selectedRecordTypes;

@property (nonatomic,strong) NSArray *selectedFolderNames;

@end
