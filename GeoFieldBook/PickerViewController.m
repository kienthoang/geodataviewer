//
//  PickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController() <UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation PickerViewController

@synthesize pickerView=_pickerView;

@synthesize componentMatrix=_componentMatrix;

- (void)setComponentMatrix:(NSArray *)componentMatrix {
    _componentMatrix=componentMatrix;
    
    //Reload the picker view
    [self.pickerView reloadAllComponents];
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.componentMatrix count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.componentMatrix objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.componentMatrix objectAtIndex:component] objectAtIndex:row];
}

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set self as the picker view's data source
    self.pickerView.dataSource=self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setPickerView:nil];
    [super viewDidUnload];
}

@end
