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

- (NSString *)userSelection {
    NSString *selection=@"";
    
    //Get all the numbers user selected in rows in all components
    for (int index=0;index<[self.componentMatrix count];index++) {
        NSArray *component=[self.componentMatrix objectAtIndex:index];
        selection=[selection stringByAppendingString:[component objectAtIndex:[self.pickerView selectedRowInComponent:index]]];    
    }
    
    return selection;
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
    
    //Set self as the picker view's data source and delegate
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
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
