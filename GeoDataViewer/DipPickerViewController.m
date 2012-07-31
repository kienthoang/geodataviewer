//
//  DipPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DipPickerViewController.h"

@interface DipPickerViewController() <UIPickerViewDelegate>

@end

@implementation DipPickerViewController

@synthesize delegate=_delegate;

#pragma mark - Picker View State Initialization

- (NSArray *)dipComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //Second component
    NSArray *secondComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
        
    return [NSArray arrayWithObjects:firstComponent,secondComponent, nil];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    [super handleUserSelection];
    
    //Notify the delegate
    [self.delegate dipPickerViewController:self userDidSelectDipValue:[self userSelection]];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup the component matrix
    self.componentMatrix=[self dipComponentMatrix]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
