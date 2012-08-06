//
//  MKStudentResponseAnnotation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Answer.h"

@interface MKStudentResponseAnnotation : NSObject <MKAnnotation>

+ (MKStudentResponseAnnotation *)annotationForStudentResponse:(Answer *)response;

@property (nonatomic,strong) Answer *response;

@end
