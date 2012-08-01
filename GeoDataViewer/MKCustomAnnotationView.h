//
//  MKCustomAnnotationView.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MKGeoRecordAnnotation.h"
#import "DipStrikeSymbol.h"

#import "Formation.h"
#import "Bedding.h"
#import "Contact.h"
#import "Other.h"

@interface MKCustomAnnotationView : MKAnnotationView

- (void)reloadAnnotationView;

@end
