//
//  ColorManager.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ColorManager.h"

@implementation ColorManager



+(UIColor *) colorWithName:(NSString *) colorName
{
    if([colorName isEqualToString:@""]) return nil;
    
    //create a dictionary of colors    
    UIColor *color = nil;
    NSArray *colorNames = [[NSArray alloc ] initWithObjects:@"Purple", @"Pink",@"Navy", @"Blue", @"Teal", @"Mocha", @"Aqua", @"Green", @"Lime", @"Olive", @"Yellow", @"Maroon", @"Red", @"Silver", @"Black", @"White", nil];
    
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

    NSDictionary *colorDictionary = [[NSDictionary alloc] initWithObjects:colors forKeys:colorNames];
    
    //now return the color 
    if([[colorDictionary allKeys] containsObject:colorName])
        color = [colorDictionary valueForKey:colorName];
    
    return color;
}


@end
