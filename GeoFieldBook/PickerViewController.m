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
@synthesize previousSelection=_previousSelection;

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

- (NSArray *)userSelectedComponentsFromSelection:(NSString *)previousSelection {
    //Split the previous selection into array of characters (DEFAULT IMPLEMENTATION)
    NSMutableArray *selectedComponents=[NSMutableArray arrayWithCapacity:[previousSelection length]];
    for (int index=0;index<[previousSelection length];index++) 
        [selectedComponents addObject:[NSString stringWithFormat:@"%c",[previousSelection characterAtIndex:index]]];
    
    return [selectedComponents copy];
}

//Will be overridden in subclasses ====> Handles user's previous selection
- (void)handlePreviousSelection:(NSString *)previousSelection {
    //Get the array of components from user's previous selection
    NSArray *userSelectedComponents=[self userSelectedComponentsFromSelection:previousSelection];
    
    //If the user selected components array is not nil, iterate through it and set the components in the picker view
    int componentIndex=0;
    for (NSString *component in userSelectedComponents) {
        //Get the row of the selected component element in the correspoding component
        int selectedComponentIndex=[[self.componentMatrix objectAtIndex:componentIndex] indexOfObject:component];
        
        //Select that row
        [self.pickerView selectRow:selectedComponentIndex inComponent:componentIndex++ animated:NO];
    }
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
    
    //If the previous selection is not blank, select the corresponding component rows
    if ([self.previousSelection length])
        [self handlePreviousSelection:self.previousSelection];    
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
