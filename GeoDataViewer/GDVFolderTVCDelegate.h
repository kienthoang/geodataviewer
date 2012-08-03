//
//  GDVFolderTVCDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVFolderTVC;
@class GDVRecordTVC;

@protocol GDVFolderTVCDelegate <NSObject>

- (void)folderTVC:(GDVFolderTVC *)sender preparedToSegueToRecordTVC:(GDVRecordTVC *)recordTVC;

@end
