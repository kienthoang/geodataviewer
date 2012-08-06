//
//  ColorManager.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ColorManager.h"
#import "SettingManager.h"

@interface ColorManager()

@property (nonatomic,strong) NSArray *colorNames;
@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) NSDictionary *colorNameDictionary;
@property (nonatomic,strong) NSDictionary *colorDictionary;

@end

@implementation ColorManager

@synthesize colorNames=_colorNames;
@synthesize colors=_colors;
@synthesize colorNameDictionary=_colorNameDictionary;
@synthesize colorDictionary=_colorDictionary;

static ColorManager *standardColorManager;

+ (void)initialize {
    [super initialize];
    
    //Setup the singleton instance
    if (!standardColorManager)
        standardColorManager=[[ColorManager alloc] init];
}

+ (ColorManager *)standardColorManager {
    return standardColorManager;
}

- (ColorManager *)init {
    if (self=[super init]) {
        //Initialize the properties
        [self initializeColorNameAndColors];
        self.colorDictionary=[NSDictionary dictionaryWithObjects:self.colors forKeys:self.colorNames];
//        self.colorNameDictionary=[NSDictionary dictionaryWithObjects:self.colorNames forKeys:self.colors];
    }
    
    return self;
}

- (void)initializeColorNameAndColors {
    self.colorNames=[NSArray arrayWithObjects:@"Purple", @"Pink",@"Navy", @"Blue", @"Teal", @"Mocha", @"Aqua", @"Green", @"Lime", @"Olive", @"Yellow", @"Maroon", @"Red", @"Silver", @"Black", @"White", nil];
    
    UIColor *purple = [UIColor purpleColor];
    UIColor *pink = [UIColor magentaColor];
    UIColor *navy = [UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:1.0f];
    UIColor *blue = [UIColor blueColor];
    UIColor *teal = [UIColor colorWithRed:0.0f green:0.5f blue:0.5f alpha:1.0f];
    UIColor *mocha = [UIColor colorWithRed:0.5f green:0.25f blue:0.0f alpha:1.0f];
    UIColor *aqua = [UIColor cyanColor];
    UIColor *green = [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    UIColor *lime = [UIColor colorWithRed:0.5f green:1.0f blue:0.0f alpha:1.0f];
    UIColor *olive = [UIColor colorWithRed:0.5f green:0.5f blue:0.0f alpha:1.0f];
    UIColor *yellow = [UIColor yellowColor];
    UIColor *maroon = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
    UIColor *red = [UIColor redColor];
    UIColor *silver = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
    UIColor *black = [UIColor blackColor];
    UIColor *white = [UIColor whiteColor];
    
    self.colors = [NSArray arrayWithObjects:purple, pink, navy, blue, teal, mocha, aqua, green, lime, olive, yellow, maroon, red, silver, black, white, nil];
}

- (UIColor *)colorWithName:(NSString *)colorName
{
    //Return the color
    SettingManager *settingManager=[SettingManager standardSettingManager];
    UIColor *color = settingManager.defaultFormationColor;
    if([self.colorNames containsObject:colorName])
        color = [self.colorDictionary objectForKey:colorName];
  
    return color;
    
}

- (NSString *)nameForColor:(UIColor *)color { 
    //Get the color name
    NSString *colorName=nil;
    if ([self.colors containsObject:color])
        colorName=[self.colorNameDictionary objectForKey:color];
    return colorName;
}


@end
