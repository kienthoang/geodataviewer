//
//  GDVFormationTVCDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVFormationTableViewController;
@class Formation;

@protocol GDVFormationTVCDelegate <NSObject>

- (BOOL)gdvFormationTVC:(GDVFormationTableViewController *)sender needsUpdateFormation:(Formation *)formation withInfo:(NSDictionary *)formationInfo;

@end
