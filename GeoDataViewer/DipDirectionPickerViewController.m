//
//  DipDirectionPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DipDirectionPickerViewController.h"
#import "Record+DipDirectionValues.h"

@interface DipDirectionPickerViewController() <UIPickerViewDelegate>

@end

@implementation DipDirectionPickerViewController

@synthesize delegate=_delegate;

#pragma mark - Picker View State Initialization

- (NSArray *)dipDirectionComponentMatrix {
    //First component
    NSMutableArray *firstComponent=[NSMutableArray arrayWithObject:DIP_DIRECTION_PICKER_BLANK_OPTION];
    [firstComponent addObjectsFromArray:[Record allDipDirectionValues]];
    
    return [NSArray arrayWithObjects:[firstComponent copy], nil];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    [super handleUserSelection];
    
    //Notify the delegate of user selection if user did not select blank option; otherwise pass an empty stirng to the delegate
    NSString *userSelection=[[self userSelection] isEqualToString:DIP_DIRECTION_PICKER_BLANK_OPTION] ? @"" : [self userSelection];
    [self.delegate dipDirectionPickerViewController:self userDidSelectDipDirectionValue:userSelection];
}

//Return the array that contains the direction (only object)
- (NSArray *)userSelectedComponentsFromSelection:(NSString *)previousSelection {
    return [NSArray arrayWithObject:previousSelection];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle selection
    [self handleUserSelection];
}


#pragma mark - View Controller Lifecycles

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Set up the component matrix
    self.componentMatrix=[self dipDirectionComponentMatrix];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
