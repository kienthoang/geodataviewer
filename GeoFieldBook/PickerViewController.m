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
@synthesize initialSelectionEnabled=_initialSelectionEnabled;

#pragma mark - Getters and Setters

- (void)setComponentMatrix:(NSArray *)componentMatrix {
    _componentMatrix=componentMatrix;
    
    //Reload the picker view
    [self.pickerView reloadAllComponents];
}

#pragma mark - User Selection Manipulation

- (NSString *)userSelection {
    NSString *selection=@"";
    
    //Get all the numbers user selected in rows in all components
    for (int index=0;index<[self.componentMatrix count];index++) {
        NSArray *component=[self.componentMatrix objectAtIndex:index];
        
        if ([component count])
            selection=[selection stringByAppendingString:[component objectAtIndex:[self.pickerView selectedRowInComponent:index]]];
    }
    
    return selection;
}

//Will be overridden in subclasses ====> Handles when user selects something (can be called by the controller to for initial selection)
- (void)handleUserSelection {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Handles initial selection if initialSelectionEnabled is set to true and there are some component rows
    if (self.initialSelectionEnabled)
        [self handleUserSelection];
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
