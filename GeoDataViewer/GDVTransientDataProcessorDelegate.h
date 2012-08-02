//
//  GDVIEEngineDelegate.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDVTransientDataProcessor;

@protocol GDVTransientDataProcessorDelegate <NSObject>

- (void)processorDidFinishProcessingRecords:(GDVTransientDataProcessor *)processor;
- (void)processorDidFinishProcessingFormations:(GDVTransientDataProcessor *)processor;
- (void)processorDidFinishProcessingStudentResponses:(GDVTransientDataProcessor *)processor;

@end
