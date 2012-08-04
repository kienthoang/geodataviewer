//
//  GDVIEEngineDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVIEEngine;

@protocol GDVIEEngineDelegate <NSObject>

- (void)engineDidFinishProcessingRecords:(GDVIEEngine *)engine;
- (void)engineDidFinishProcessingFormations:(GDVIEEngine *)engine;
- (void)engineDidFinishProcessingStudentResponses:(GDVIEEngine *)engine;

@end
