//
//  RecordMapViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordMapViewController.h"
#import "FilterByRecordTypeController.h"
#import "MKGeoRecordAnnotation.h"
#import "MKMapRecordInfoViewController.h"
#import "Image.h"

@interface RecordMapViewController() <MKMapViewDelegate,MKMapRecordInfoDelegate>

@property (weak,nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) UIPopoverController *filterPopover;
@property (nonatomic,strong) UIPopoverController *annotationCalloutPopover;

@property (nonatomic,strong) NSArray *mapAnnotations;

#define RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER @"Record Annotation View"

@end

@implementation RecordMapViewController

@synthesize records=_records;
@synthesize selectedRecord=_selectedRecord;

@synthesize mapView = _mapView;
@synthesize mapDelegate=_mapDelegate;
@synthesize mapAnnotations=_mapAnnotations;

@synthesize filterPopover=_filterPopover;
@synthesize annotationCalloutPopover=_annotationCalloutPopover;

- (void)updateMapView {
    if ([self.records count]) {
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
        
        //Save the annotations
        self.mapAnnotations=self.mapView.annotations;
        
        //Set the location span of the map
        self.mapView.region=[self regionFromLocations];
    }
}

- (void)setSelectedRecord:(Record *)selectedRecord {
    //Deselect the previous record if it's not nil
    if (self.selectedRecord) {
        for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.record==self.selectedRecord) {
                [self.mapView deselectAnnotation:annotation animated:YES];
                break;
            }
        }
    }
    
    //Save the new selected record
    _selectedRecord=selectedRecord;
            
    //Select the pin corresponding to the record
    for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.record==self.selectedRecord) {
            //Set the location span and the center of the map
            self.mapView.region=[self regionFromLocations];
            self.mapView.centerCoordinate=annotation.coordinate;
            [self.mapView selectAnnotation:annotation animated:YES];
            break;
        }
    }
}

#pragma mark - Getters and Setters

- (void)setRecords:(NSArray *)records {
    if (_records!=records) {
        _records=records;
        
        [self updateMapView];
    }
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
    
    //Switch map to satellite mode
    self.mapView.mapType=MKMapTypeSatellite;
    
    //Ask the delegate for records to display
    self.records=[self.mapDelegate recordsForMapViewController:self];
        
    //Show user location
    self.mapView.showsUserLocation=YES;
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
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    //Get an annotation view
    MKPinAnnotationView *annotationView=(MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
    if (!annotationView) {
        annotationView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
        annotationView.canShowCallout=YES;
        
        //Set up the left view of the callout (where the image of the record is showed)
        annotationView.leftCalloutAccessoryView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        //Make the right view of the callout an info button
        UIButton *infoButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
        infoButton.frame=CGRectMake(0, 0, 15, 15);
        annotationView.rightCalloutAccessoryView=infoButton;
    }
    
    //Set up the annotation view
    annotationView.annotation=annotation;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    //Show the image
    MKGeoRecordAnnotation *annotation=view.annotation;
    Record *record=annotation.record;
    UIImage *recordImage=[UIImage imageWithData:record.image.imageData];
    [(UIImageView *)view.leftCalloutAccessoryView setImage:recordImage];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control 
{
    //Dismiss the callout
    [self.mapView deselectAnnotation:view.annotation animated:NO];
    
    //Dismiss the old annotation callout popover if it's visible on screen
    if (self.annotationCalloutPopover.isPopoverVisible) {
        [self.annotationCalloutPopover dismissPopoverAnimated:NO];
        self.annotationCalloutPopover=nil;
    }

    //show the popover
    MKMapRecordInfoViewController *recordInfo=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Info Popover"];
    MKGeoRecordAnnotation *annotation=view.annotation;
    recordInfo.record=annotation.record;
    recordInfo.delegate=self;
    UIPopoverController *annotationCalloutPopover=[[UIPopoverController alloc] initWithContentViewController:recordInfo];
    annotationCalloutPopover.popoverContentSize=CGSizeMake(330, 110);
    [annotationCalloutPopover presentPopoverFromRect:view.bounds 
                                              inView:view 
                            permittedArrowDirections:UIPopoverArrowDirectionAny 
                                            animated:YES];
    self.annotationCalloutPopover=annotationCalloutPopover;
    
    //Notify the map delegate of user's selection
    //[self.mapDelegate mapViewController:self userDidSelectAnnotationForRecord:annotation.record switchToDataView:NO];
}

#pragma mark - Determine span of map view

- (MKCoordinateRegion)regionFromLocations {
    // Get the upper and lower coordinates for the location span
    CLLocationCoordinate2D upper=[[self.mapAnnotations objectAtIndex:0] coordinate];
    CLLocationCoordinate2D lower=[[self.mapAnnotations objectAtIndex:0] coordinate];
    for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
        if (annotation.coordinate.longitude>upper.longitude) upper.longitude=annotation.coordinate.longitude;
        if (annotation.coordinate.latitude>upper.latitude) upper.latitude=annotation.coordinate.latitude;
        if (annotation.coordinate.longitude<lower.longitude) lower.longitude=annotation.coordinate.longitude;
        if (annotation.coordinate.latitude<lower.latitude) lower.latitude=annotation.coordinate.latitude;
    }
    
    // Set the spans for the location span
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta=upper.latitude-lower.latitude;
    locationSpan.longitudeDelta=upper.longitude-lower.longitude;
    
    // Determine the center of the location span
    CLLocationCoordinate2D locationCenter;
    locationCenter.longitude=(upper.longitude+lower.longitude)/2;
    locationCenter.latitude=(upper.latitude+lower.latitude)/2;
    
    return MKCoordinateRegionMake(locationCenter, locationSpan);
}

#pragma mark - MKMapRecordInfoViewControllerDelegate methods

- (void)mapRecordInfoViewController:(MKMapRecordInfoViewController *)sender 
 userDidTapOnAccessoryViewForRecord:(Record *)record 
{
    //Notify the delegate
    [self.mapDelegate mapViewController:self userDidSelectAnnotationForRecord:record switchToDataView:YES];
    
    //Dismiss the callout popover
    [self.annotationCalloutPopover dismissPopoverAnimated:NO];
}

@end
