//
//  RecordMapViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordMapViewController.h"
#import "MKGeoRecordAnnotation.h"

@interface RecordMapViewController() <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

#define RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER @"Record Annotation View"

@end

@implementation RecordMapViewController

@synthesize mapView = _mapView;
@synthesize records=_records;
@synthesize mapDelegate=_mapDelegate;

- (void)updateMapView {
    //Convert the array of records into annotations
    NSMutableArray *annotations=[NSMutableArray arrayWithCapacity:self.records.count];
    for (Record *record in self.records)
        [annotations addObject:[MKGeoRecordAnnotation annotationForRecord:record]];
    
    //Remove the old annotations
    if (self.mapView.annotations)
        [self.mapView removeAnnotations:self.mapView.annotations];
    
    //Add new annotations
    if ([annotations count])
        [self.mapView addAnnotations:[annotations copy]];
}

#pragma mark - Getters and Setters

- (void)setRecords:(NSArray *)records {
    _records=records;
    
    [self updateMapView];
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView=mapView;
    self.mapView.delegate=self;
    
    [self updateMapView];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the delegate of the map view
    self.mapView.delegate=self;
    
    //Ask the delegate for records to display
    self.records=[self.mapDelegate recordsForMapViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Ask the delegate for records to display
    //self.records=[self.mapDelegate recordsForMapViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //Get an annotation view
    MKAnnotationView *annotationView=[self.mapView dequeueReusableAnnotationViewWithIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
    if (!annotationView) {
        annotationView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
        annotationView.canShowCallout=YES;
    }
    
    //Set up the annotation view
    annotationView.annotation=annotation;
    
    return annotationView;
}

@end
