//
//  FormationPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationPickerViewController.h"
#import "Formation.h"

@interface FormationPickerViewController() <UIPickerViewDelegate>

@end

@implementation FormationPickerViewController

@synthesize formations=_formations;
@synthesize pickerName=_pickerName;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (void)setFormations:(NSArray *)formations {
    if (![_formations isEqualToArray:formations]) {
        _formations=formations;
        
        //Reload the picker
        [self.pickerView reloadAllComponents];
    }
}

- (NSArray *)componentMatrix {
    return [self pickerViewComponentMatrixFromFormations:self.formations];
}

#pragma mark - User Selection Manipulation

- (void)handleUserSelection {
    //Notify the user of user selection if user did not select the blank option; otherwise pass an empty string to the delegate
    NSString *userSelection=[[self userSelection] isEqualToString:FORMATION_PICKER_BLANK_OPTION] ? @"" : [self userSelection];
    [self.delegate formationPickerViewController:self userDidSelectFormationWithName:userSelection];
}

- (NSArray *)userSelectedComponentsFromSelection:(NSString *)previousSelection {
    return [NSArray arrayWithObject:previousSelection];
}

#pragma mark - UIPickerViewControllerDelegate

- (void)pickerView:(UIPickerView *)pickerView 
      didSelectRow:(NSInteger)row 
       inComponent:(NSInteger)component
{
    //Handle user selection
    [self handleUserSelection];
}

#pragma mark - Picker View State Initialization

- (NSArray *)pickerViewComponentMatrixFromFormations:(NSArray *)formations {
    NSMutableArray *formationNames=[NSMutableArray arrayWithCapacity:[formations count]];
    //Add blank option
    [formationNames addObject:FORMATION_PICKER_BLANK_OPTION];
    
    //Add the names of the formations
    for (Formation *formation in formations)
        [formationNames addObject:formation.formationName];
    
    //Component matrix of size 1 (the only element is the array of formation names)
    return [NSArray arrayWithObject:[formationNames copy]];
}

#pragma mark - View Controller Life Cycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load the components for the picker view
    self.componentMatrix=[self pickerViewComponentMatrixFromFormations:self.formations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end