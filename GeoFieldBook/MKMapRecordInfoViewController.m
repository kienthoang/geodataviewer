//
//  MKMapRecordInfoViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKMapRecordInfoViewController.h"
#import "Record+DateAndTimeFormatter.h"
#import "Formation.h"
#import "Other.h"
#import "Contact.h"

@interface MKMapRecordInfoViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *recordName;
@property (weak, nonatomic) IBOutlet UILabel *recordType;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;
@property (weak, nonatomic) IBOutlet UILabel *formation;
@property (weak, nonatomic) IBOutlet UILabel *dipDirection;
@property (weak, nonatomic) IBOutlet UILabel *dip;
@property (weak, nonatomic) IBOutlet UILabel *strike;

@end

@implementation MKMapRecordInfoViewController

@synthesize imageView=_imageView;
@synthesize recordName=_recordName;
@synthesize recordType=_recordType;
@synthesize recordDate=_recordDate;
@synthesize recordTime=_recordTime;
@synthesize formation = _formation;
@synthesize dipDirection = _dipDirection;
@synthesize dip = _dip;
@synthesize strike = _strike;

@synthesize delegate=_delegate;

@synthesize record=_record;

#pragma mark - Target-Action Handlers

- (IBAction)accessoryTapped:(UIButton *)sender {
    //Notify the delegate
    [self.delegate mapRecordInfoViewController:self 
            userDidTapOnAccessoryViewForRecord:self.record];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the info
    self.imageView.image=[UIImage imageWithData:self.record.image.imageData];
    self.recordName.text=self.record.name;
    self.recordType.text=[self.record.class description];
    self.recordDate.text=[Record dateFromNSDate:self.record.date];
    self.recordTime.text=[Record timeFromNSDate:self.record.date];
    id record=self.record;
    self.formation.text=([record isKindOfClass:[Contact class]] || [record isKindOfClass:[Other class]]) ? @"N/A" : [(Formation *)[record formation] formationName];
    self.dip.text=self.record.dip ? [NSString stringWithFormat:@"%@",self.record.dip] : @"N/A";
    self.strike.text=self.record.strike ? [NSString stringWithFormat:@"%@",self.record.strike] : @"N/A";
    self.dipDirection.text=self.record.dipDirection ? self.record.dipDirection : @"N/A";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setRecordName:nil];
    [self setRecordType:nil];
    [self setRecordDate:nil];
    [self setRecordTime:nil];
    [self setFormation:nil];
    [self setDipDirection:nil];
    [self setDip:nil];
    [self setStrike:nil];
    [super viewDidUnload];
}
@end
