//
//  ModalRecordTypeSelector.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ModalRecordTypeSelector.h"

@interface ModalRecordTypeSelector() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *recordTypePicker;

@end

@implementation ModalRecordTypeSelector

@synthesize recordTypePicker=_recordTypePicker;
@synthesize recordTypes=_recordTypes;
@synthesize delegate=_delegate;

//In case the recordTypePicker gets set to a new picker view, set the new one's delegate and data source to self
- (void)setRecordTypePicker:(UIPickerView *)recordTypePicker {
    if (_recordTypePicker!=recordTypePicker) {
        _recordTypePicker=recordTypePicker;
        self.recordTypePicker.delegate=self;
        self.recordTypePicker.dataSource=self;
    }
}

//Reload the record type picker view when the model changes
- (void)setRecordTypes:(NSArray *)recordTypes {
    if (_recordTypes!=recordTypes) {
        _recordTypes=recordTypes;
        [self.recordTypePicker reloadAllComponents];
        
        NSLog(@"Types: %@",recordTypes);
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set self as the delegate and data source of the record picker view
    self.recordTypePicker.delegate=self;
    self.recordTypePicker.dataSource=self;
    
    //Resize self to fit the master view
    self.view.superview.frame=CGRectMake(0, 0, 300, 400);
    self.view.superview.center=CGPointMake(0, 0);
}

- (void)viewDidUnload
{
    [self setRecordTypePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIPickerViewDataSource methods

//Only 1 component
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//Just return the number of record types
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.recordTypes count];
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.recordTypes objectAtIndex:row];
}

#pragma mark - Target-Action Handlers

- (IBAction)addRecordPressed:(UIBarButtonItem *)sender {
    //Pass the record type user chose to the delegate

}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
