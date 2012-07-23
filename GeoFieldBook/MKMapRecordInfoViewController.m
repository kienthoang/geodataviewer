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
@property (weak, nonatomic) IBOutlet UILabel *upperFormation;
@property (weak, nonatomic) IBOutlet UILabel *lowerFormation;
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
@synthesize upperFormation = _upperFormation;
@synthesize lowerFormation = _lowerFormation;
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
    Record *record=self.record;
    self.imageView.image=[UIImage imageWithData:self.record.image.imageData];
    self.recordName.text=record.name;
    self.recordType.text=[record.class description];
    self.recordDate.text=[Record dateFromNSDate:record.date];
    self.recordTime.text=[Record timeFromNSDate:record.date];
    self.dip.text=record.dip ? [NSString stringWithFormat:@"%@",record.dip] : @"N/A";
    self.strike.text=record.strike ? [NSString stringWithFormat:@"%@",record.strike] : @"N/A";
    self.dipDirection.text=record.dipDirection ? record.dipDirection : @"N/A";
    
    if ([record isKindOfClass:[Contact class]]) {
        Contact *contact=(Contact *)record;
        self.upperFormation.text=contact.upperFormation.formationName;
        self.lowerFormation.text=contact.lowerFormation.formationName;
    } else if ([record isKindOfClass:[Other class]]) {
        self.formation.text=@"N/A";
    } else {
        self.formation.text=[(Formation *)[(id)record formation] formationName];
    }
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
    [self setUpperFormation:nil];
    [self setLowerFormation:nil];
    [super viewDidUnload];
}
@end
