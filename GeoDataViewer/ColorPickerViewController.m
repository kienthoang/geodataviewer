//
//  ColorPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController() 

@property (weak, nonatomic) IBOutlet UIButton *purplePatch;
@property (weak, nonatomic) IBOutlet UIButton *fuchsiaPatch;
@property (weak, nonatomic) IBOutlet UIButton *navyPatch;
@property (weak, nonatomic) IBOutlet UIButton *bluePatch;
@property (weak, nonatomic) IBOutlet UIButton *tealPatch;
@property (weak, nonatomic) IBOutlet UIButton *mochaPatch;
@property (weak, nonatomic) IBOutlet UIButton *aquaPatch;
@property (weak, nonatomic) IBOutlet UIButton *greenPatch;
@property (weak, nonatomic) IBOutlet UIButton *limePatch;
@property (weak, nonatomic) IBOutlet UIButton *olivePatch;
@property (weak, nonatomic) IBOutlet UIButton *yellowPatch;
@property (weak, nonatomic) IBOutlet UIButton *maroonPatch;
@property (weak, nonatomic) IBOutlet UIButton *redPatch;
@property (weak, nonatomic) IBOutlet UIButton *silverPatch;
@property (weak, nonatomic) IBOutlet UIButton *blackPatch;
@property (weak, nonatomic) IBOutlet UIButton *whitePatch;

@property (nonatomic,readonly) NSArray *colorPatches;

@end

@implementation ColorPickerViewController 

#pragma mark - View Controller Lifecycle
@synthesize purplePatch = _purplePatch;
@synthesize fuchsiaPatch = _fuchsiaPatch;
@synthesize navyPatch = _navyPatch;
@synthesize bluePatch = _bluePatch;
@synthesize tealPatch = _tealPatch;
@synthesize mochaPatch = _mochaPatch;
@synthesize aquaPatch = _aquaPatch;
@synthesize greenPatch = _greenPatch;
@synthesize limePatch = _limePatch;
@synthesize olivePatch = _olivePatch;
@synthesize yellowPatch = _yellowPatch;
@synthesize maroonPatch = _maroonPatch;
@synthesize redPatch = _redPatch;
@synthesize silverPatch = _silverPatch;
@synthesize blackPatch = _blackPatch;
@synthesize whitePatch = _whitePatch;

@synthesize selectedColor=_selectedColor;
@synthesize colorName=_colorName;


@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (NSArray *)colorPatches {
    return [NSArray arrayWithObjects:
            self.purplePatch,
            self.fuchsiaPatch,
            self.navyPatch,
            self.bluePatch,
            self.tealPatch,
            self.mochaPatch,
            self.aquaPatch,
            self.greenPatch,
            self.limePatch,
            self.olivePatch,
            self.yellowPatch,
            self.maroonPatch,
            self.redPatch,
            self.silverPatch,
            self.blackPatch,
            self.whitePatch,nil];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (![_selectedColor isEqual:selectedColor]) {
        _selectedColor=selectedColor;
    }
}

-(void)setColorName:(NSString *)colorName {
    if(![_colorName isEqualToString:colorName])
       _colorName = colorName;
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

- (void)updateSelectedColor:(UIColor *)color andName:(NSString *) colorName{
    //Notify the delegate
    [self.delegate colorPicker:self userDidSelectColor:color withName:(NSString *)colorName];
    
    //Save the selected color
    self.selectedColor=color;
}

- (IBAction)colorPatchPressed:(UIButton *)colorPatch {
    //Get the color represented by the color patch
    UIColor *selectedColor=colorPatch.backgroundColor;
    self.colorName = colorPatch.titleLabel.text;
    //Update
    [self updateSelectedColor:selectedColor andName:self.colorName];
    
    //NSLog(@"Color Description: %@ Name: %@ ", [selectedColor description], self.colorName);
    
}

- (void)viewDidUnload {
    [self setPurplePatch:nil];
    [self setFuchsiaPatch:nil];
    [self setNavyPatch:nil];
    [self setBluePatch:nil];
    [self setTealPatch:nil];
    [self setMochaPatch:nil];
    [self setAquaPatch:nil];
    [self setGreenPatch:nil];
    [self setLimePatch:nil];
    [self setOlivePatch:nil];
    [self setYellowPatch:nil];
    [self setMaroonPatch:nil];
    [self setRedPatch:nil];
    [self setSilverPatch:nil];
    [self setBluePatch:nil];
    [self setWhitePatch:nil];
    [super viewDidUnload];
}



@end
