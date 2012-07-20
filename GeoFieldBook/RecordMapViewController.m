//
//  RecordMapViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordMapViewController.h"
#import "FilterByRecordTypeController.h"
#import "GeoFilter.h"
#import "MKGeoRecordAnnotation.h"
#import "MKMapRecordInfoViewController.h"
#import "Image.h"

@interface RecordMapViewController() <MKMapViewDelegate,MKMapRecordInfoDelegate,FilterRecordsByType>

@property (nonatomic,weak) UIPopoverController *filterPopover;
@property (nonatomic,strong) UIPopoverController *annotationCalloutPopover;
@property (nonatomic, strong) NSMutableSet *recordsTypesToDisplay;

@property (nonatomic,strong) NSArray *mapAnnotations;

@property (nonatomic,strong) GeoFilter *recordFilter;

#define RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER @"Record Annotation View"

@end

@implementation RecordMapViewController

@synthesize records=_records;

@synthesize mapView = _mapView;
@synthesize mapAnnotations=_mapAnnotations;

@synthesize filterPopover=_filterPopover;
@synthesize annotationCalloutPopover=_annotationCalloutPopover;

@synthesize recordsTypesToDisplay=_recordsTypesToDisplay;

@synthesize recordFilter=_recordFilter;
@synthesize selectedRecord=_selectedRecord;

@synthesize mapDelegate=_mapDelegate;

#pragma mark - Map View Setup methods

- (void)updateMapView {
    //Filter the records
    NSArray *records=[self.recordFilter filterRecordCollectionByRecordType:self.records];
     
    //Remove the old annotations
    if (self.mapView.annotations) {
        NSMutableArray *removedAnnotations=[NSMutableArray arrayWithCapacity:self.mapView.annotations.count];
        for (id <MKAnnotation> annotation in self.mapView.annotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]])
                [removedAnnotations addObject:annotation];
        }
        
        [self.mapView removeAnnotations:removedAnnotations.copy];
    }
    
    //Reset the saved annotations
    self.mapAnnotations=[NSArray array];
    
    self.mapView.centerCoordinate=self.mapView.userLocation.coordinate;
    
    //Set up the annotations for the map view
    if (records.count) {
        //Convert the array of records into annotations
        for (Record *record in records)
            [self.mapView addAnnotation:[MKGeoRecordAnnotation annotationForRecord:record]];

        //Save the annotations
        self.mapAnnotations=self.mapView.annotations;
        
        //Set the location span of the map
        self.mapView.region=[self regionFromLocationsUserLocationIncluded:NO];
        
        CLLocationCoordinate2D center = [self.mapView centerCoordinate];
        [self.mapView setCenterCoordinate:center];
    }    
}

#pragma mark - Getters and Setters

- (GeoFilter *)recordFilter {
    if (!_recordFilter)
        _recordFilter=[[GeoFilter alloc] init];
    
    return _recordFilter;
}

- (void)setRecords:(NSArray *)records {
    //If the records actually changed
    if (![_records isEqualToArray:records]) {
        _records=records;
        
        [self updateMapView];
    }
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView=mapView;
    self.mapView.delegate=self;
    
    [self updateMapView];
}

- (void)deselectAnnotationForRecord:(Record *)selectedRecord {
    //Deselect the previous record if it's not nil
    if (selectedRecord) {
        for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.record==selectedRecord) {
                [self.mapView deselectAnnotation:annotation animated:YES];
                break;
            }
        }
    }
}

- (void)selectAnnotationForRecord:(Record *)selectedRecord {
    if (selectedRecord) {
        for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.record==selectedRecord) {
                //Set the location span and the center of the map
                self.mapView.centerCoordinate=annotation.coordinate;
                [self.mapView selectAnnotation:annotation animated:YES];
                break;
            }
        }
    }
}

- (void)setSelectedRecord:(Record *)selectedRecord {
    //Deselect current record
    [self deselectAnnotationForRecord:self.selectedRecord];
    
    //Save the new selected record
    _selectedRecord=selectedRecord;
    
    //Select the pin corresponding to the record
    [self selectAnnotationForRecord:self.selectedRecord];
}

#pragma mark - Prepare for Segues

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Filter By Record Type"]){
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setSelectedRecordTypes:self.recordFilter.selectedRecordTypes];
        [segue.destinationViewController setAllRecordTypes:self.recordFilter.allRecordTypes];
    }
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the delegate of the map view
    self.mapView.delegate=self;
    
    //Switch map to satellite mode
    self.mapView.mapType=MKMapTypeSatellite;
        
    //Show user location
    self.mapView.showsUserLocation=YES;
    
    //Update records
    self.records=[self.mapDelegate recordsForMapViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Update the map view
    //self.records=[self.mapDelegate recordsForMapViewController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Reselect the selected record if its annotation view is not currently selected
    MKGeoRecordAnnotation *annotation=self.mapView.selectedAnnotations.lastObject;
    if (self.selectedRecord && self.selectedRecord!=annotation.record)
        self.selectedRecord=self.selectedRecord;
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
    if (![view.annotation isKindOfClass:[MKUserLocation class]]) {
        MKGeoRecordAnnotation *annotation=view.annotation;
        Record *record=annotation.record;
        UIImage *recordImage=[UIImage imageWithData:record.image.imageData];
        [(UIImageView *)view.leftCalloutAccessoryView setImage:recordImage];
    }
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
    [annotationCalloutPopover presentPopoverFromRect:view.bounds 
                                              inView:view 
                            permittedArrowDirections:UIPopoverArrowDirectionAny 
                                            animated:YES];
    self.annotationCalloutPopover=annotationCalloutPopover;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    //Drop-pin animation
    for (MKAnnotationView *view in views) {
        CGRect endFrame = view.frame;
        
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - 300.0, view.frame.size.width, view.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [view setFrame:endFrame];
        [UIView commitAnimations];
        
    }
}


#pragma mark - Determine span of map view

- (MKCoordinateRegion)regionFromLocationsUserLocationIncluded:(BOOL)userLocationIncluded {
    // Get the upper and lower coordinates for the location span
    CLLocationCoordinate2D upper=[[self.mapAnnotations objectAtIndex:0] coordinate];
    CLLocationCoordinate2D lower=[[self.mapAnnotations objectAtIndex:0] coordinate];
    for (MKGeoRecordAnnotation *annotation in self.mapAnnotations) {
        if (userLocationIncluded || (!userLocationIncluded && ![annotation isKindOfClass:[MKUserLocation class]])) {
            if (annotation.coordinate.longitude>upper.longitude) 
                upper.longitude=annotation.coordinate.longitude;
            if (annotation.coordinate.latitude>upper.latitude) 
                upper.latitude=annotation.coordinate.latitude;
            if (annotation.coordinate.longitude<lower.longitude) 
                lower.longitude=annotation.coordinate.longitude;
            if (annotation.coordinate.latitude<lower.latitude) 
                lower.latitude=annotation.coordinate.latitude;
        }
    }
    
    // Set the spans for the location span
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta=upper.latitude-lower.latitude+0.01;
    locationSpan.longitudeDelta=upper.longitude-lower.longitude+0.01;
    
    // Determine the center of the location span
    CLLocationCoordinate2D locationCenter;
    locationCenter.longitude=(upper.longitude+lower.longitude)/2;
    locationCenter.latitude=(upper.latitude+lower.latitude)/2;
    
    return MKCoordinateRegionMake(locationCenter, locationSpan);
}

#pragma mark - FilterByRecordType delegate method

- (void)filterByTypeController:(FilterByRecordTypeController *)sender userDidSelectRecordType:(NSString *)recordType {
    //Add the selected record type
    [self.recordFilter userDidSelectRecordType:recordType];
    
    //Update the map view
    [self updateMapView];
    
    //Notify the delegate of the selected record types
    if ([self.mapDelegate respondsToSelector:@selector(userDidChooseToDisplayRecordTypes:)])
        [self.mapDelegate userDidChooseToDisplayRecordTypes:self.recordFilter.selectedRecordTypes];
}

- (void)filterByTypeController:(FilterByRecordTypeController *)sender userDidDeselectRecordType:(NSString *)recordType {
    //Remove the selected record type
    [self.recordFilter userDidDeselectRecordType:recordType];
    
    //Update the map view
    [self updateMapView];
    
    //Notify the delegate of the selected record types
    if ([self.mapDelegate respondsToSelector:@selector(userDidChooseToDisplayRecordTypes:)])
        [self.mapDelegate userDidChooseToDisplayRecordTypes:self.recordFilter.selectedRecordTypes];
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
