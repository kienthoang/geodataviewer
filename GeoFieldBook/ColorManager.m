//
//  ColorManager.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager
@synthesize colorDictionary=_colorDictionary;

//constructor that initializes the color dictionary
-(id)init {
    self = [super init];
    if(self) {
        NSArray *colorNames = [[NSArray alloc ] initWithObjects:@"Purple", @"Pink",@"Navy", @"Blue", @"Teal", @"Mocha", @"Aqua", @"Green", @"Lime", @"Olive", @"Yellow", @"Maroon", @"Red", @"Silver", @"Black", @"White", nil];
        
        //the sixteen colors
        UIColor *purple = [UIColor purpleColor];
        UIColor *pink = [UIColor magentaColor];
        UIColor *navy = [[UIColor alloc] initWithRed:0.0f green:0.0f blue:0.5f alpha:1.0f];
        UIColor *blue = [UIColor blueColor];
        UIColor *teal = [[UIColor alloc] initWithRed:0.0f green:0.5f blue:0.5f alpha:1.0f];
        UIColor *mocha = [[UIColor alloc] initWithRed:0.5f green:0.25f blue:0.0f alpha:1.0f];
        UIColor *aqua = [UIColor cyanColor];
        UIColor *green = [UIColor greenColor];
        UIColor *lime = [[UIColor alloc] initWithRed:0.5f green:1.0f blue:0.0f alpha:1.0f];
        UIColor *olive = [[UIColor alloc] initWithRed:0.5f green:0.5f blue:0.0f alpha:1.0f];
        UIColor *yellow = [UIColor yellowColor];
        UIColor *maroon = [[UIColor alloc] initWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
        UIColor *red = [UIColor redColor];
        UIColor *silver = [[UIColor alloc] initWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        UIColor *black = [UIColor blackColor];
        UIColor *white = [UIColor whiteColor];
        
        NSArray *colors = [[NSArray alloc] initWithObjects:purple, pink, navy, blue, teal, mocha, aqua, green, lime, olive, yellow, maroon, red, silver, black, white, nil];
        
        self.colorDictionary = [[NSDictionary alloc] initWithObjects:colors forKeys:colorNames];
    }
    return self;
}

-(UIColor *) colorWithName:(NSString *)colorName 
{
    if([colorName isEqualToString:@""]) return nil;
    
    UIColor *color = nil;
    
    //now return the color 
    if([[self.colorDictionary allKeys] containsObject:colorName])
        color = [self.colorDictionary valueForKey:colorName];
    
    return color;
    
}



@end
