//
//  InitialDetailViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "InitialDetailViewController.h"
#import "RecordViewController.h"
#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"

@interface InitialDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *geofieldbookLogo;

@end

@implementation InitialDetailViewController

@synthesize geofieldbookLogo = _geofieldbookLogo;

#pragma mark - View Controller Lifecycles

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Center the geofieldbook logo
    CGRect frame=self.geofieldbookLogo.frame;
    CGFloat centerX=(self.view.bounds.size.width-frame.size.width)/2;
    CGFloat centerY=(self.view.bounds.size.height-frame.size.height)/2;
    self.geofieldbookLogo.frame=CGRectMake(centerX, centerY, frame.size.width, frame.size.height); 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setGeofieldbookLogo:nil];
    [super viewDidUnload];
}
@end
