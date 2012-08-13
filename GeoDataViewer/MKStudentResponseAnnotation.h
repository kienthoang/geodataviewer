//
//  MKStudentResponseAnnotation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/5/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Response_Record.h"

@interface MKStudentResponseAnnotation : NSObject <MKAnnotation>

+ (MKStudentResponseAnnotation *)annotationForStudentResponseRecord:(Response_Record *)responseRecord;

@property (nonatomic,strong) Response_Record *responseRecord;

@end
