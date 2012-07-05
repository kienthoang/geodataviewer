//
//  GeoMapAnnotationProvider.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

@protocol GeoMapAnnotationProvider <NSObject>

- (NSArray *)recordsForMapViewController:(UIViewController *)mapViewController;
- (void)mapViewController:(UIViewController *)mapViewController userDidSelectAnnotationForRecord:(Record *)record;

@end
