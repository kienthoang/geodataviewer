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

@synthesize responseRecord=_responseRecord;

+ (MKStudentResponseAnnotation *)annotationForStudentResponseRecord:(Response_Record *)responseRecord {
    MKStudentResponseAnnotation *annotation=[[MKStudentResponseAnnotation alloc] init];
    annotation.responseRecord=responseRecord;
    
    return annotation;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=self.responseRecord.latitude.doubleValue;
    coordinate.longitude=self.responseRecord.longitude.doubleValue;
    
    return coordinate;
}

- (NSString *)title {
    NSString *title=[NSString stringWithFormat:@"%@'s Responses",self.responseRecord.group.name];
    return title;
}

@end
