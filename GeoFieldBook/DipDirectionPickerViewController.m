//
//  DipDirectionPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DipDirectionPickerViewController.h"

@interface DipDirectionPickerViewController() <UIPickerViewDelegate>

@end

@implementation DipDirectionPickerViewController

@synthesize delegate=_delegate;

- (NSArray *)dipDirectionComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects:@"N", @"NE", @"E",@"SE" , @"S", @"SW", @"W", @"NW", nil];
    
    return [NSArray arrayWithObjects:firstComponent, nil];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Notify the delegate
    [self.delegate dipDirectionPickerViewController:self userDidSelectDipDirectionValue:[self userSelection]];
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
