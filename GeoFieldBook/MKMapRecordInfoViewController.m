//
//  MKMapRecordInfoViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKMapRecordInfoViewController.h"
#import "Record+DateAndTimeFormatter.h"

@interface MKMapRecordInfoViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *recordName;
@property (weak, nonatomic) IBOutlet UILabel *recordType;
@property (weak, nonatomic) IBOutlet UILabel *recordDate;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;

@end

@implementation MKMapRecordInfoViewController

@synthesize imageView=_imageView;
@synthesize recordName=_recordName;
@synthesize recordType=_recordType;
@synthesize recordDate=_recordDate;
@synthesize recordTime=_recordTime;

@synthesize record=_record;

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the info
    self.imageView.image=[UIImage imageWithData:self.record.image.imageData];
    self.recordName.text=self.record.name;
    self.recordType.text=[self.record.class description];
    self.recordDate.text=[Record dateFromNSDate:self.record.date];
    self.recordTime.text = [Record timeFromNSDate:self.record.date];
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
    [super viewDidUnload];
}
@end
