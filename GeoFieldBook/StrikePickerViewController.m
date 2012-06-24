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

- (NSArray *)strikeComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
    
    //Second component
    NSArray *secondComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    //Third component
    NSArray *thirdComponent=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    
    return [NSArray arrayWithObjects:firstComponent,secondComponent,thirdComponent, nil];
}

- (void)notifyDelegateOfUserSelection {
    NSString *strike=@"";
    
    //Get all the numbers user selected in rows in all components
    for (int index=0;index<[self.componentMatrix count];index++) {
        NSArray *component=[self.componentMatrix objectAtIndex:index];
        strike=[strike stringByAppendingString:[component objectAtIndex:[self.pickerView selectedRowInComponent:index]]];    
    }
    
    //Pass the strike to the delegate
    [self.delegate strikePickerViewController:self userDidSelectStrikeValue:strike];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self notifyDelegateOfUserSelection];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set self as the picker view's delegate
    self.pickerView.delegate=self;
    
    //Setup the component matrix
    self.componentMatrix=[self strikeComponentMatrix];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
