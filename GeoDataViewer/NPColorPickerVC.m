//
//  NPColorPickerVC.m
//  GeoDataViewer
//
//  Created by excel 2011 on 8/6/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "NPColorPickerVC.h"

@interface NPColorPickerVC ()

@end

@implementation NPColorPickerVC
@synthesize picker=_picker;
@synthesize quad=_quad;
@synthesize delegate=_delegate;
@synthesize selectedColors=_selectedColors;

- (IBAction)donePickingColor:(id)sender {
    self.picker.color = self.quad.selectedColor;
    [self.delegate userDidDismissPopoverWithColor:self.quad.selectedColor andSelectedColors:self.quad.getSelectedColors];    
}
- (IBAction)addColor:(id)sender {
    [self.quad pushColor:self.picker.color];    
}

-(void) pushInitialColors:(NSMutableArray *) colors 
{
    for(UIColor *color in colors) {
        [self.quad pushColor:color];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
}

-(void) viewWillAppear:(BOOL)animated 
{
    //set up the four initial colors
    [self pushInitialColors:self.selectedColors];
}
- (void)viewDidUnload
{
    [self setPicker:nil];
    [self setQuad:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
