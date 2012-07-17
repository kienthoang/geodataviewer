//
//  MNColorSelectionViewController.m
//  MindNodeTouch
//
//  Created by Markus Müller on 24.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MNColorSelectionViewController.h"
#import "MNColorView.h"
#import "UIColor+ColorSpaces.h"
#import "NSArray+HOM.h"

@interface MNColorSelectionViewController ()

@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSMutableArray *colorViews;

- (void)layoutViews;

// Loading
- (void)_loadSingleNodeViews;
- (void)_loadGroupedNodeViews;

@end

@implementation MNColorSelectionViewController

#pragma mark - Creation Convenience

+ (id)selectionViewControllerWithPallet:(NSString *)pallete addDarkenedVariants:(BOOL)darkenedVariants
{
    NSArray *colorsArray = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:pallete withExtension:@"plist"]];
    if (!colorsArray) return nil;
    
    NSMutableArray *colorList = [NSMutableArray arrayWithCapacity:[colorsArray count]];
    for (id currentColorRepresentation in colorsArray) {
        
        UIColor *currentColor = [UIColor mn_colorFromPropertyRepresentation:currentColorRepresentation];
        if (!currentColor) continue;
        [colorList addObject:currentColor];
        
        if (!darkenedVariants) continue;
        for (NSUInteger index = 0; index < 3; index++) {
            currentColor = [currentColor mn_darkenedColor];
            [colorList addObject:currentColor];
        }
    }

    if (![colorsArray count]) return nil;
    
    MNColorSelectionViewController *colorsViewController = [[[self class] alloc] initWithColors:colorList];
    return [colorsViewController autorelease];
}


+ (id)monoChromeSelectionViewController
{
    MNColorSelectionViewController *colorsViewController = [[self class] selectionViewControllerWithPallet:@"MNColorsBlackWhite" addDarkenedVariants:NO]; 
    colorsViewController.title = NSLocalizedStringFromTable(@"Monochrome", @"inspector", @"title of black white color list");
    return colorsViewController;
}


+ (id)modernColorsSelectionViewController
{
    MNColorSelectionViewController *colorsViewController = [[self class] selectionViewControllerWithPallet:@"colorsModern" addDarkenedVariants:YES];
    colorsViewController.title = NSLocalizedStringFromTable(@"Vintage", @"inspector", @"title of vintage color list");
    return colorsViewController;
}    
 
+ (id)vintageColorsSelectionViewController
{     
    MNColorSelectionViewController *colorsViewController = [[self class] selectionViewControllerWithPallet:@"colorsVintage" addDarkenedVariants:YES]; 
    colorsViewController.title = NSLocalizedStringFromTable(@"Vintage", @"inspector", @"title of vintage color list");
    return colorsViewController;
}


+ (id)rainbowSelectionViewController
{   
    MNColorSelectionViewController *colorsViewController = [[self class] selectionViewControllerWithPallet:@"MNColorsRainbow" addDarkenedVariants:NO]; 
    colorsViewController.title = NSLocalizedStringFromTable(@"Rainbow", @"inspector", @"title of black white color list");
    return colorsViewController;
}

+ (id)colorsFromUserDefaults:(NSString *)userDefaultsKey
{ 
    NSMutableArray *vintageColorList = [NSMutableArray arrayWithCapacity:7];
    for (NSData *currentData in [[NSUserDefaults standardUserDefaults] arrayForKey:userDefaultsKey]) {
        UIColor *currentColor = [NSKeyedUnarchiver unarchiveObjectWithData:currentData];
		[vintageColorList addObject:currentColor];
        for (NSUInteger index = 0; index < 3; index++) {
            currentColor = [currentColor mn_darkenedColor];
            [vintageColorList addObject:currentColor];
        }
    }
    if (![vintageColorList count]) return nil;
    
    MNColorSelectionViewController *colorsViewController = [[[self class] alloc] initWithColors:vintageColorList];
    
    return [colorsViewController autorelease];
}


#pragma mark - Properties

@synthesize colors=_colors;
@synthesize colorViews=_colorViews;
@synthesize delegate=_delegate;

#pragma mark - Creation

- (id)initWithColors:(NSArray *)colors
{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    
    NSUInteger colorCount = [colors count];
        NSAssert((colorCount <= 6 || (colorCount % 4) == 0), @"If you provide more than 6 colors, the colors need to be mod 4!");
    self.colors = colors;
    
    return self;
}

- (void)dealloc
{
    MNRelease(_colors);
    MNRelease(_colorViews);
    [super dealloc];
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
    
    NSUInteger colorCount = [self.colors count];
    self.colorViews = [NSMutableArray arrayWithCapacity:colorCount];
    if (colorCount <= 6) {
        [self _loadSingleNodeViews];
    } else {
        [self _loadGroupedNodeViews];
    }
}

- (void)_loadSingleNodeViews
{
    NSUInteger colorCount = [self.colors count];
    for (NSUInteger index = 0; index < colorCount; index++) {
        
        MNColorView *colorView = [MNColorView colorViewWithColor:[self.colors objectAtIndex:index] borderStyle:MNColorViewBorderStyleSingle];
        [self.view addSubview:colorView];
        [self.colorViews addObject:colorView];
        [colorView addTarget:self action:@selector(didTapOnColorView:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)_loadGroupedNodeViews
{
    NSUInteger colorCount = [self.colors count];
    for (NSUInteger index = 0; index < colorCount / 4; index++) {
        for (NSUInteger innerIndex = 0; innerIndex < 4; innerIndex++) {
            MNColorViewBorderStyle borderStyle;
            switch (innerIndex) {
                case 0:
                    borderStyle = MNColorViewBorderStyleTop;
                    break;
                case 1:
                case 2:
                    borderStyle = MNColorViewBorderStyleMiddle;
                    break;
                case 3:
                    borderStyle = MNColorViewBorderStyleBottom;
                    break;
            }
            NSUInteger currentIndex = index*4+innerIndex;
            MNColorView *colorView = [MNColorView colorViewWithColor:[self.colors objectAtIndex:currentIndex] borderStyle:borderStyle];
            [self.view addSubview:colorView];
            [self.colorViews addObject:colorView];
            [colorView addTarget:self action:@selector(didTapOnColorView:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    for (MNColorView *currentView in self.colorViews) {
        [currentView removeFromSuperview];
    }
    self.colorViews = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutViews];
    
    UIColor *selectedColor = [self.delegate colorSelectionControllerSelectedColor:self];
    for (NSUInteger index = 0; index < [self.colors count]; index++) {
        UIColor *currentColor = [self.colors objectAtIndex:index];
        [[self.colorViews objectAtIndex:index] setSelected:([currentColor isEqual:selectedColor]) animated:NO];
    }
}

#pragma mark - Layout


- (void)layoutViews
{
    CGFloat xOffset = 9;
    CGFloat yOffset = 14.f;
    CGFloat width = 95;
    CGFloat height = 43*4;
    
    CGRect colorRect = CGRectMake(xOffset, yOffset, width, height);
    NSUInteger viewCount = [self.colorViews count];
    
    if (viewCount <= 6) {
        for (NSUInteger index = 0; index < viewCount; index++) {
            colorRect.origin.x = xOffset + (width+xOffset)*(index % 3);
            colorRect.origin.y = yOffset + (height+yOffset)*(NSUInteger)(index / 3);
            [[self.colorViews objectAtIndex:index] setFrame:colorRect];
        }
    } else {
        viewCount = viewCount / 4;
        for (NSUInteger index = 0; index < viewCount; index++) {
            colorRect.origin.x = xOffset + (width+xOffset)*(index % 3);
            colorRect.origin.y = yOffset + (height+yOffset)*(NSUInteger)(index / 3);
            
            for (NSUInteger innerIndex = 0; innerIndex < 4; innerIndex++) {
                CGRect frame = colorRect;
                frame.size.height = frame.size.height/4;
                frame.origin.y += frame.size.height * innerIndex;
                NSUInteger currentIndex = index*4+innerIndex;
                [[self.colorViews objectAtIndex:currentIndex] setFrame:frame];
            }
        }
    }
}

#pragma mark - Actions

- (void)didTapOnColorView:(MNColorView *)colorView
{
    [[self.colorViews mn_makeObjectsPerform] setSelected:NO];
    colorView.selected = YES;
    [self.delegate colorSelectionController:self didSelectedColor:colorView.color];
}

@end
