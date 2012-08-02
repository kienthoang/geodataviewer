//
//  GDVController.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVController.h"

@interface GDVController() <ImportTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation GDVController

@synthesize contentView = _contentView;

@synthesize recordList=_recordList;
@synthesize feedbackList=_feedbackList;
@synthesize formationListPopover=_formationListPopover;

@synthesize mapViewController=_mapViewController;

#pragma mark - Getters and Setters

- (GDVResourceManager *)resourceManager {
    return [GDVResourceManager defaultResourceManager];
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Segue to record list
    NSString *segueIdentifier=segue.identifier;
    if ([segueIdentifier isEqualToString:@"Record List"])
         self.recordList=[self.storyboard instantiateViewControllerWithIdentifier:@"Record List"];
    
    //Segue to feedback list
    else if ([segueIdentifier isEqualToString:@"Feedback List"])
        self.feedbackList=[self.storyboard instantiateViewControllerWithIdentifier:@"Feedback List"];
    
    //Segue to map view
    else if ([segueIdentifier isEqualToString:@"Map View"]) {
        //Instantiate the map vc
        self.mapViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"Map View"];
        
        //Add map vc as child vc
        RecordMapViewController *mapViewController=self.mapViewController;
        self.mapViewController.view.frame=self.contentView.bounds;
        [mapViewController willMoveToParentViewController:self];
        [self addChildViewController:mapViewController];
        [self.contentView addSubview:mapViewController.mapView];
        [mapViewController didMoveToParentViewController:self];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Perform custom segues
    [self performSegueWithIdentifier:@"Record List" sender:nil];
    [self performSegueWithIdentifier:@"Feedback List" sender:nil];
    [self performSegueWithIdentifier:@"Map View" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [super viewDidUnload];
}

#pragma mark - ImportTableViewControllerDelegate Protocol Methods

- (void)userDidSelectRecordCSVFiles:(NSArray *)records forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
}

- (void)userDidSelectFormationCSVFiles:(NSArray *)formations forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
}

- (void)userDidSelectFeedbackCSVFiles:(NSArray *)feedbacks forImportingInImportTVC:(ImportTableViewController *)sender
{
    //Update the model
}

@end
