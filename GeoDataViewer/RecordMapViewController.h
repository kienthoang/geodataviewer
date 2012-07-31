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
#import "Record.h"

@interface RecordMapViewController : UIViewController

@property (nonatomic,strong) NSArray *records;
@property (nonatomic,strong) Record *selectedRecord;

@property (weak,nonatomic) IBOutlet MKMapView *mapView;

@property (weak,nonatomic) id <RecordMapViewControllerDelegate> mapDelegate;

#define kDEFAULTCLUSTERSIZE 0.2

- (void)updateRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion;
- (void)reloadAnnotationViews;

@end
