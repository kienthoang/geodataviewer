//
//  GeoFilter.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoFilter : NSObject

- (void)userDidSelectRecordType:(NSString *)recordType;   //Add user's selection

- (void)userDidSelectFolderName:(NSString *)folderName;   //Add user's selection

- (NSSet *)selectedRecordTypes;           //Returns the array of record types user selected

- (NSSet *)selectedFolderNames;           //Returns the array of folder names user selected

- (NSArray *)filterRecordCollection:(NSArray *)records;    //Filters the specified array of records and returns the results

@end
