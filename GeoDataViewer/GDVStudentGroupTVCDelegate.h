//
//  GDVStudentGroupTVCDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVStudentGroupTVC;
@class GDVFolderTVC;
@class GDVStudentResponseTVC;

@protocol GDVStudentGroupTVCDelegate <NSObject>

- (void)studentGroupTVC:(GDVStudentGroupTVC *)sender preparedToSegueToFolderTVC:(GDVFolderTVC *)folderTVC;
- (void)studentGroupTVC:(GDVStudentGroupTVC *)sender preparedToSegueToStudentResponseTVC:(GDVStudentResponseTVC *)studentResponseTVC;

@optional

- (void)updateStudentGroupsForStudenGroupTVC:(GDVStudentGroupTVC *)sender;
- (void)studentGroupTVC:(GDVStudentGroupTVC *)sender deleteStudentGroups:(NSArray *)studentGroups;

@end
