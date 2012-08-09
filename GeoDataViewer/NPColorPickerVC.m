//
//  NPColorPickerVC.m
//  GeoDataViewer
//
//  Created by excel 2011 on 8/6/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "NPColorPickerVC.h"

@interface NPColorPickerVC ()<NPColorPickerViewDelegate, NPColorQuadViewDelegate>

@end

@implementation NPColorPickerVC
@synthesize picker=_picker;
@synthesize quad=_quad;
@synthesize delegate=_delegate;
@synthesize selectedColors=_selectedColors;



- (IBAction)addPressed:(UIButton *)sender {
    NSLog(@"add tapped");
    [self.quad pushColor:self.picker.color];
    
}

-(void) pushInitialColors:(NSMutableArray *) colors 
{ 
    for(UIColor *color in colors) {
        [self.quad pushColor:color];
    }
}

-(void) setPickerColor:(UIColor *) color 
{
    [self.picker setColor:color];
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
    self.picker.delegate=self;
    self.quad.delegate=self;
    //set up the four initial colors
    [self pushInitialColors:self.selectedColors];
    
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.delegate userDidDismissPopover:self.quad.getSelectedColors];

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

#pragma mark - NPColorPickerView protocol methods
-(void) NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color
{
    [self.delegate userDidSelectColor:color];    
}

#pragma mark - NPColorQuadView protocol methods
-(void) userDidSelectColorTile:(UIColor *)color 
{
    [self.picker setColor:color];
    [self.delegate userDidSelectColor:color];
}

@end
