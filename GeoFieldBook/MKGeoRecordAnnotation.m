//
//  MKGeoRecordAnnotation.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKGeoRecordAnnotation.h"

@implementation MKGeoRecordAnnotation

@synthesize record=_record;

+ (MKGeoRecordAnnotation *)annotationForRecord:(Record *)record {
    MKGeoRecordAnnotation *annotation=[[MKGeoRecordAnnotation alloc] init];
    annotation.record=record;
    
    return annotation;
}

- (NSString *)title {
    return self.record.name;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=[self.record.latitude doubleValue];
    coordinate.longitude=[self.record.longitude doubleValue];
    
    return coordinate;
}

@end
