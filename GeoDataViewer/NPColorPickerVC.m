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

- (IBAction)donePickingColor:(id)sender {
    [self.quad pushColor:self.picker.color];
    [self.delegate userDidDismissPopoverWithColor:self.picker.color];
    
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
	// Do any additional setup after loading the view.
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
