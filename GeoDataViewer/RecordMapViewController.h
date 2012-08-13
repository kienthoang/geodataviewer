//
//  RecordMapViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "RecordMapViewControllerDelegate.h"

#import "MKRecordAnnotationView.h"
#import "MKResponseAnnotationView.h"

@interface RecordMapViewController : UIViewController

@property (nonatomic,strong) NSArray *records;
@property (nonatomic,strong) NSArray *responseRecords;

@property (nonatomic,strong) Record *selectedRecord;
@property (nonatomic,strong) Answer *selectedResponse;

@property (weak,nonatomic) IBOutlet MKMapView *mapView;

@property (weak,nonatomic) id <RecordMapViewControllerDelegate> mapDelegate;

- (void)updateRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion;
- (void)updateResponseRecords:(NSArray *)responseRecords forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion;
- (void)reloadAnnotationViews;

@end
