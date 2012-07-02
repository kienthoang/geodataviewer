//
//  GeoMapAnnotationProvider.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol GeoMapAnnotationProvider

- (NSArray *)recordsForMapView:(MKMapView *)mapView;    //Returns an array of records

@end
