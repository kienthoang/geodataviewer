//
//  StrikePickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "StrikePickerViewController.h"

@interface StrikePickerViewController() <UIPickerViewDelegate>

@end

@implementation StrikePickerViewController

@synthesize delegate=_delegate;

#pragma mark - Picker View State Initialization

- (NSArray *)strikeComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
    
    //Second component
    NSArray *secondComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //Third component
    NSArray *thirdComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    return [NSArray arrayWithObjects:firstComponent,secondComponent,thirdComponent, nil];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    [super handleUserSelection];
    
    //Notify the delegate of user's selection
    [self.delegate strikePickerViewController:self userDidSelectStrikeValue:[self userSelection]];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the component matrix
    self.componentMatrix=[self strikeComponentMatrix];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end