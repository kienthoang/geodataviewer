//
//  MKGeoRecordAnnotation.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Record.h"

@interface MKGeoRecordAnnotation : NSObject <MKAnnotation>

+ (MKGeoRecordAnnotation *)annotationForRecord:(Record *)record;

@property (nonatomic,strong) Record *record;

@end
