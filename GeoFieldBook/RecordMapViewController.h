//
//  RecordMapViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeoMapAnnotationProvider.h"

@interface RecordMapViewController : UIViewController

@property (nonatomic,weak) id <GeoMapAnnotationProvider> mapDelegate;
@property (nonatomic,strong) NSArray *records;

@end
