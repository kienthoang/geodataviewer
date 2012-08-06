//
//  MKStudentResponseAnnotation.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKStudentResponseAnnotation.h"

#import "Group.h"

@implementation MKStudentResponseAnnotation

@synthesize response=_response;

+ (MKStudentResponseAnnotation *)annotationForStudentResponse:(Answer *)response {
    MKStudentResponseAnnotation *annotation=[[MKStudentResponseAnnotation alloc] init];
    annotation.response=response;
    
    return annotation;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=self.response.latitude.doubleValue;
    coordinate.longitude=self.response.longitude.doubleValue;
    
    return coordinate;
}

- (NSString *)title {
    NSString *title=[NSString stringWithFormat:@"%@'s response",self.response.group.name];
    return title;
}

@end
