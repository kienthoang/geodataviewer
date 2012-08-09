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

#import "MKMapRecordInfoViewController.h"
#import "Image.h"

#import "Bedding.h"
#import "Contact.h"

#import "SettingManager.h"

@interface RecordMapViewController() <MKMapViewDelegate,MKMapRecordInfoDelegate,FilterRecordsByType>

@property (nonatomic,weak) UIPopoverController *filterPopover;
@property (nonatomic,strong) UIPopoverController *annotationCalloutPopover;
@property (nonatomic, strong) NSMutableSet *recordsTypesToDisplay;

@property (nonatomic,strong) NSArray *mapAnnotations;
@property (nonatomic,strong) NSArray *recordAnnotations;
@property (nonatomic,strong) NSArray *responseAnnotations;

@property (nonatomic,strong) GeoFilter *recordFilter;

#define RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER @"Record Annotation View"
#define RESPONSE_ANNOTATION_VIEW_REUSE_IDENTIFIER @"Responses Annotation View"

@end

@implementation RecordMapViewController

@synthesize mapView = _mapView;

@synthesize records=_records;
@synthesize responses=_responses;

@synthesize mapAnnotations=_mapAnnotations;
@synthesize recordAnnotations=_recordAnnotations;
@synthesize responseAnnotations=_responseAnnotations;

@synthesize filterPopover=_filterPopover;
@synthesize annotationCalloutPopover=_annotationCalloutPopover;

@synthesize recordsTypesToDisplay=_recordsTypesToDisplay;
@synthesize recordFilter=_recordFilter;

@synthesize selectedRecord=_selectedRecord;
@synthesize selectedResponse=_selectedResponse;

@synthesize mapDelegate=_mapDelegate;

#pragma mark - Getters and Setters

- (NSArray *)mapAnnotations {
    if (!_mapAnnotations)
        _mapAnnotations=[NSArray array];
    
    return _mapAnnotations;
}

#pragma mark - Map View Setup methods

- (void)updateMapView:(MKMapView *)mapView forRecords:(NSArray *)records willUpdateRegion:(BOOL)willUpdateRegion {
    //Filter the records
    records=[self.recordFilter filterRecordCollectionByRecordType:records];
     
    //Save the old region
    MKCoordinateRegion mapRegion=mapView.region;
    
    //Remove the old record annotations
    if (mapView.annotations) {
        NSMutableArray *removedAnnotations=[NSMutableArray arrayWithCapacity:self.recordAnnotations.count];
        for (id <MKAnnotation> annotation in self.recordAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]])
                [removedAnnotations addObject:annotation];
        }
        
        [mapView removeAnnotations:removedAnnotations.copy];
    }
    
    //Reset the saved annotations
    NSMutableArray *recordAnnotations=[NSMutableArray array];
    NSMutableArray *mapAnnotations=self.mapAnnotations.mutableCopy;
    [mapAnnotations removeObjectsInArray:self.recordAnnotations];
    
    mapView.centerCoordinate=mapView.userLocation.coordinate;
    
    //Set up the annotations for the map view
    if (records.count) {
        //Convert the array of records into annotations
        for (Record *record in records) {
            MKGeoRecordAnnotation *annotation=[MKGeoRecordAnnotation annotationForRecord:record];
            [mapView addAnnotation:annotation];
            [recordAnnotations addObject:annotation];
        }

        //Save the annotations
        self.recordAnnotations=recordAnnotations.copy;
        [mapAnnotations addObjectsFromArray:self.recordAnnotations];
        self.mapAnnotations=mapAnnotations.copy;
        
        //Set the location span of the map if desired
        if (willUpdateRegion)
            mapView.region=[self regionFromLocationsUserLocationIncluded:NO];
        else
            mapView.region=mapRegion;
        
        CLLocationCoordinate2D center = [mapView centerCoordinate];
        [mapView setCenterCoordinate:center];
    }    
}

- (void)updateMapView:(MKMapView *)mapView forResponses:(NSArray *)responses willUpdateRegion:(BOOL)willUpdateRegion {
    //Filter the responses
    //recorresponsesds=[self.recordFilter filterRecordCollectionByRecordType:records];
    
    //Save the old region
    MKCoordinateRegion mapRegion=mapView.region;
    
    //Remove the old responses annotations
    if (mapView.annotations) {
        NSMutableArray *removedAnnotations=[NSMutableArray arrayWithCapacity:self.responseAnnotations.count];
        for (id <MKAnnotation> annotation in self.responseAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]])
                [removedAnnotations addObject:annotation];
        }
        
        [mapView removeAnnotations:removedAnnotations.copy];
    }
    
    //Reset the saved annotations
    NSMutableArray *responseAnnotations=[NSMutableArray array];
    NSMutableArray *mapAnnotations=self.mapAnnotations.mutableCopy;
    [mapAnnotations removeObjectsInArray:self.responseAnnotations];
    
    mapView.centerCoordinate=mapView.userLocation.coordinate;
    
    //Set up the annotations for the map view
    if (responses.count) {
        //Convert the array of records into annotations
        for (Answer *response in responses) {
            MKStudentResponseAnnotation *annotation=[MKStudentResponseAnnotation annotationForStudentResponse:response];
            [mapView addAnnotation:annotation];
            [responseAnnotations addObject:annotation];
        }
        
        //Save the annotations
        self.responseAnnotations=responseAnnotations.copy;
        [mapAnnotations addObjectsFromArray:self.responseAnnotations];
        self.mapAnnotations=mapAnnotations.copy;
        
        //Set the location span of the map if desired
        if (willUpdateRegion)
            mapView.region=[self regionFromLocationsUserLocationIncluded:NO];
        else
            mapView.region=mapRegion;
        
        CLLocationCoordinate2D center = [mapView centerCoordinate];
        [mapView setCenterCoordinate:center];
    }        
}


#pragma mark - Getters and Setters

- (GeoFilter *)recordFilter {
    if (!_recordFilter)
        _recordFilter=[[GeoFilter alloc] init];
    
    return _recordFilter;
}

- (void)updateRecords:(NSArray *)records forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion {
    if ((willForceUpdate && self.records!=records) || (!willForceUpdate && ![self.records isEqualToArray:records])) {
        self.records=records;
        [self updateMapView:self.mapView forRecords:self.records willUpdateRegion:willUpdateRegion];
    }
}

- (void)updateResponses:(NSArray *)responses forceUpdate:(BOOL)willForceUpdate updateRegion:(BOOL)willUpdateRegion {
    if ((willForceUpdate && self.responses!=responses) || (!willForceUpdate && ![self.responses isEqualToArray:responses])) {
        self.responses=responses;
        [self updateMapView:self.mapView forResponses:self.responses willUpdateRegion:willUpdateRegion];
    }
}

- (void)reloadAnnotationViews {
    //Redraw all annotation views
    for (MKGeoRecordAnnotation *annotation in self.mapView.annotations) {
        MKAnnotationView *annotationView=[self.mapView viewForAnnotation:annotation];
        if ([annotationView isKindOfClass:[MKRecordAnnotationView class]]) {
            //Reload annotation view 
            MKRecordAnnotationView *customAnnotationView=(MKRecordAnnotationView *)annotationView;
            [customAnnotationView reloadAnnotationView];
        }
    }
}

- (void)setMapView:(MKMapView *)mapView {
    _mapView=mapView;
    self.mapView.delegate=self;
    
    //update the map initially
    [self updateMapView:mapView forRecords:self.records willUpdateRegion:YES];
    [self updateMapView:mapView forResponses:self.responses willUpdateRegion:YES];
}

- (void)deselectAnnotationForRecord:(Record *)selectedRecord {
    //Deselect the previous record if it's not nil
    if (selectedRecord) {
        for (MKGeoRecordAnnotation *annotation in self.recordAnnotations) {
            if (![annotation isKindOfClass:[MKUserLocation class]] && annotation.record==selectedRecord) {
                [self.mapView deselectAnnotation:annotation animated:YES];
                break;
            }
        }
    }
}

- (void)selectAnnotationForRecord:(Record *)selectedRecord {
    if (selectedRecord) {
        for (MKGeoRecordAnnotation *annotation in self.recordAnnotations) {
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

#pragma mark - Notification Center

- (void)formationColorSettingDidChange:(NSNotification *)notification {
    //Reload the annotation views' colors
    [self reloadAnnotationViews];
}

- (void)registerForNotifications {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(formationColorSettingDidChange:) name:SettingManagerUserPreferencesDidChange object:nil];
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
    [self.mapDelegate updateRecordsForMapViewController:self];    
    
    //Register for notifications
    [self registerForNotifications];
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

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)annotation {
    //If the given annotation is a record annotation
    if ([annotation isKindOfClass:[MKGeoRecordAnnotation class]]) {
        MKGeoRecordAnnotation *recordAnnotation=(MKGeoRecordAnnotation *)annotation;
        //Get the record of the annotation
        Record *record=recordAnnotation.record;
        
        //If the record is of type bedding or contact return a MKCustomAnnotationView
        if ([record isKindOfClass:[Bedding class]] || [record isKindOfClass:[Contact class]])
            return [[MKRecordAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
        
        return [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
    }
    
    //Else if the given annotation is a response annotation
    else if ([annotation isKindOfClass:[MKStudentResponseAnnotation class]]) {
        return [[MKResponseAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:RESPONSE_ANNOTATION_VIEW_REUSE_IDENTIFIER];        
    }
    
    return nil;
}

- (BOOL)annotationView:(MKAnnotationView *)annotationView isCorrectKindOfAnnotationViewFor:(Record *)record {
    if ([record isKindOfClass:[Bedding class]] || [record isKindOfClass:[Contact class]])
        return [annotationView isKindOfClass:[MKRecordAnnotationView class]];
    else
        return [annotationView isKindOfClass:[MKPinAnnotationView class]];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView=nil;
        
    //Else if it's a single record annotation
    if ([annotation isKindOfClass:[MKGeoRecordAnnotation class]]) {
        //Get an annotation view
        annotationView=[self.mapView dequeueReusableAnnotationViewWithIdentifier:RECORD_ANNOTATION_VIEW_REUSE_IDENTIFIER];
        
        Record *record=[(MKGeoRecordAnnotation *)annotation record];
        if (!annotationView || ![self annotationView:annotationView isCorrectKindOfAnnotationViewFor:record]) {
            annotationView=[self viewForAnnotation:annotation];
            annotationView.canShowCallout=YES;
            
            //Set up the left view of the callout (where the image of the record is showed)
            annotationView.leftCalloutAccessoryView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            
            //Make the right view of the callout an info button
            UIButton *infoButton=[UIButton buttonWithType:UIButtonTypeInfoLight];
            infoButton.frame=CGRectMake(0, 0, 15, 15);
            annotationView.rightCalloutAccessoryView=infoButton;
        }
    }
    
    //Else if it is a response annotation 
    else if ([annotation isKindOfClass:[MKStudentResponseAnnotation class]]) {
        //Get an annotation view
        annotationView=[self.mapView dequeueReusableAnnotationViewWithIdentifier:RESPONSE_ANNOTATION_VIEW_REUSE_IDENTIFIER];
        
        if (!annotationView) {
            annotationView=[self viewForAnnotation:annotation];
            annotationView.canShowCallout=YES;
        }
    }
    
    //Set up the annotation view
    annotationView.annotation=annotation;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    //Show the image if the annotation view is a record annotation view
    if ([view.annotation isKindOfClass:[MKRecordAnnotationView class]]) {
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

    if ([view isKindOfClass:[MKRecordAnnotationView class]]) {
        //show the popover
        MKGeoRecordAnnotation *annotation=view.annotation;
        Record *record=annotation.record;
        MKMapRecordInfoViewController *recordInfo=[record isKindOfClass:[Contact class]] ? [self.storyboard instantiateViewControllerWithIdentifier:@"Contact Info Popover"] :
        [self.storyboard instantiateViewControllerWithIdentifier:@"Non-Contact Info Popover"];
        recordInfo.record=record;
        recordInfo.delegate=self;
        UIPopoverController *annotationCalloutPopover=[[UIPopoverController alloc] initWithContentViewController:recordInfo];
        [annotationCalloutPopover presentPopoverFromRect:view.bounds 
                                                  inView:view 
                                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                animated:YES];
        self.annotationCalloutPopover=annotationCalloutPopover;
    }
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
    
    for (id <MKAnnotation> annotation in self.mapAnnotations) {
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
    [self updateMapView:self.mapView forRecords:self.records willUpdateRegion:YES];
}

- (void)filterByTypeController:(FilterByRecordTypeController *)sender userDidDeselectRecordType:(NSString *)recordType {
    //Remove the selected record type
    [self.recordFilter userDidDeselectRecordType:recordType];
    
    //Update the map view
    [self updateMapView:self.mapView forRecords:self.records willUpdateRegion:YES];
}

#pragma mark - MKMapRecordInfoViewControllerDelegate methods

- (void)mapRecordInfoViewController:(MKMapRecordInfoViewController *)sender 
 userDidTapOnAccessoryViewForRecord:(Record *)record 
{
    //Dismiss the callout popover
    [self.annotationCalloutPopover dismissPopoverAnimated:NO];
}

@end
