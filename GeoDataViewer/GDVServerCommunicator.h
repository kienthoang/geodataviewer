//
//  GDVServerCommunicator.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDVTransientDataProcessor.h"

@interface GDVServerCommunicator : NSObject

+ (GDVServerCommunicator *)serverCommunicatorWithProcessor:(GDVTransientDataProcessor *)processor;

@property (nonatomic,strong) GDVTransientDataProcessor *processor;

@end
