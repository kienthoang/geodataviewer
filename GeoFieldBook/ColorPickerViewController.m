//
//  ColorPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController() <NPColorPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *redPatch;
@property (weak, nonatomic) IBOutlet UIButton *yellowPatch;
@property (weak, nonatomic) IBOutlet UIButton *greenPatch;
@property (weak, nonatomic) IBOutlet UIButton *cyanPatch;
@property (weak, nonatomic) IBOutlet UIButton *plumPatch;
@property (weak, nonatomic) IBOutlet UIButton *mochaPatch;
@property (weak, nonatomic) IBOutlet UIButton *cloverPatch;
@property (weak, nonatomic) IBOutlet UIButton *bluePatch;

@property (nonatomic,readonly) NSArray *colorPatches;

@end

@implementation ColorPickerViewController 

#pragma mark - View Controller Lifecycle
@synthesize redPatch = _redPatch;
@synthesize yellowPatch = _yellowPatch;
@synthesize greenPatch = _greenPatch;
@synthesize cyanPatch = _cyanPatch;
@synthesize plumPatch = _plumPatch;
@synthesize mochaPatch = _mochaPatch;
@synthesize cloverPatch = _cloverPatch;
@synthesize bluePatch = _bluePatch;

@synthesize selectedColor=_selectedColor;

@synthesize colorPickerView=_colorPickerView;

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (NSArray *)colorPatches {
    return [NSArray arrayWithObjects:
            self.redPatch,
            self.yellowPatch,
            self.greenPatch,
            self.cyanPatch,
            self.plumPatch,
            self.mochaPatch,
            self.cloverPatch,
            self.bluePatch, nil];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (![_selectedColor isEqual:selectedColor]) {
        _selectedColor=selectedColor;
        
        //Update the color picker view
        self.colorPickerView.color=self.selectedColor;
    }
}

- (void)setColorPickerView:(NPColorPickerView *)colorPickerView {
    _colorPickerView=colorPickerView;
    
    //Set self as the delegate of the color picker view
    self.colorPickerView.delegate=self;
}

#pragma mark - View Controller Lifecycle

- (void)styleColorPatches {
    //Style the color patches
    for (UIButton *colorPatch in self.colorPatches) {
        colorPatch.layer.borderColor=[UIColor blackColor].CGColor;
        colorPatch.layer.cornerRadius=8.0f;
        colorPatch.layer.borderWidth=1.0f;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Style the color patches
    [self styleColorPatches];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Color Patches

- (void)updateSelectedColor:(UIColor *)color {
    //Notify the delegate
    [self.delegate colorPicker:self userDidSelectColor:color];
    
    //Save the selected color
    self.selectedColor=color;
}

- (IBAction)colorPatchPressed:(UIButton *)colorPatch {
    //Get the color represented by the color patch
    UIColor *selectedColor=colorPatch.backgroundColor;
    
    //Update
    [self updateSelectedColor:selectedColor];
}

- (void)viewDidUnload {
    [self setRedPatch:nil];
    [self setYellowPatch:nil];
    [self setGreenPatch:nil];
    [self setCyanPatch:nil];
    [self setPlumPatch:nil];
    [self setMochaPatch:nil];
    [self setCloverPatch:nil];
    [self setBluePatch:nil];
    [super viewDidUnload];
}

#pragma mark - NPColorPickerView Delegate methods

- (void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color {
    [self updateSelectedColor:color];
}

@end
