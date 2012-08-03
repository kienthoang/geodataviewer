//
//  GDVServerCommunicator.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVServerCommunicator.h"

@implementation GDVServerCommunicator

@synthesize processor=_processor;

+ (GDVServerCommunicator *)serverCommunicatorWithProcessor:(GDVTransientDataProcessor *)processor {
    GDVServerCommunicator *serverCommunicator=[[GDVServerCommunicator alloc] init];
    serverCommunicator.processor=processor;
    
    return serverCommunicator;
}

@end
