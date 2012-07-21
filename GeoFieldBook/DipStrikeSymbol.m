//
//  DipStrikeSymbol.m
//  Test
//
//  Created by excel2011 on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DipStrikeSymbol.h"
#import "Record+DipDirectionValues.h"

@implementation DipStrikeSymbol

@synthesize strike=_strike;
@synthesize dip=_dip;
@synthesize dipDirection=_dipDirection;
@synthesize color=_color;

#pragma mark - Setters

- (void)setStrike:(float)strike {
    _strike=strike;
    
    //Redraw
    [self setNeedsDisplay];
}

- (void)setDip:(float)dip {
    _dip=dip;
    
    //Redraw
    [self setNeedsDisplay];
}

- (void)setDipDirection:(NSString *)dipDirection {
    _dipDirection=dipDirection;
    
    //Redraw
    [self setNeedsDisplay];
}

- (UIColor *)color {
    if (!_color)
        self.color=[UIColor blackColor];
    
    return _color;
}

#pragma mark - Getters

- (NSString *)dipDirection {
    if (!_dipDirection.length)
        return @"N";
    
    return _dipDirection;
}

#define PI 3.14159

- (float) toRadians:(float) degrees
{
    return degrees * PI / 180;
}

- (void) drawStrikeWithContext:(CGContextRef) context point:(CGPoint) point1 andPoint:(CGPoint) point2 withColor:(UIColor *) color
{
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    [color setStroke];
    CGContextStrokePath(context);
}

- (void) drawDipWithContext:(CGContextRef) context from:(CGPoint) center to:(CGPoint) point withColor:(UIColor *) color
{
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, point.x, point.y);
    [color setStroke];
    CGContextStrokePath(context);
}

- (CGPoint) closestPointTo:(CGPoint) givenDipPoint among:(CGPoint) dipPoint1 or:(CGPoint) dipPoint2
{
    float givenDipToDipPoint1 = sqrtf(powf(dipPoint1.x-givenDipPoint.x, 2.0) + powf(dipPoint1.y-givenDipPoint.y, 2.0));
    float givenDipToDipPoint2 = sqrtf(powf(dipPoint2.x-givenDipPoint.x, 2.0) + powf(dipPoint2.y-givenDipPoint.y, 2.0));
    
    return givenDipToDipPoint1 > givenDipToDipPoint2 ? dipPoint2 : dipPoint1;
}

- (void)drawRect:(CGRect)rect 
{
    //CONVERT TO RADIANS
    [super drawRect:rect];
    
    if (self.dipDirection) {
        //STRIKE
        
        //input from user    
        CGPoint center;
        CGFloat width=self.bounds.size.width;
        CGFloat height=self.bounds.size.height;
        center.x=self.bounds.origin.x+width/2;
        center.y=self.bounds.origin.y+height/2;
        float radius = sqrtf(width*width+height*height)/2;
        
        float strike=[self toRadians:self.strike];
        CGPoint point1 = CGPointMake(radius * sin(strike) + center.x, -radius * cos(strike) + center.y);
        CGPoint point2 = CGPointMake(-radius * sin(strike) + center.x, radius * cos(strike) + center.y);
        
        //Draw the strike
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 3.0);
        CGContextBeginPath(context);
        
        //draw surrounding circle or ellipse
        //CGContextAddArc(context, center.x, center.y, radius, 0.0, 2*PI, 0);
        //CGContextAddEllipseInRect(context, CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height));
        //[[UIColor whiteColor] setFill];
        //CGContextFillPath(context);

        [self drawStrikeWithContext:context point:point1 andPoint:point2 withColor:self.color];
        
        //DIP
        //the dip line is always perpendicular to the strike line
        //we determine which side of the strike line the dip line will appear based on the dip direction given by the user...
        //whichever side is closer to this direction is the side on which the dip line is drawn
        //if the dip direction corresponds exactly with the strike line (which it should not, this is likely an error in measurement I think), the dip line is drawn towards dipPoint1 (see below) (90 degrees clockwise from the strike angle given by the user)
        
        //if the dip direction is used to determine the direction of the dip these two arrays are required
        NSArray *dipDirectionConversions = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:45], [NSNumber numberWithInt:90], [NSNumber numberWithInt:135], [NSNumber numberWithInt:180], [NSNumber numberWithInt:225], [NSNumber numberWithInt:270], [NSNumber numberWithInt:315], nil];
        NSArray *possibleDips = [Record allDipDirectionValues];
        
        //input from the user
        NSString *dipdirection = self.dipDirection;
        
        float dipAngle = [[dipDirectionConversions objectAtIndex:[possibleDips indexOfObject:dipdirection]] floatValue];
        dipAngle = [self toRadians:dipAngle];
        
        float strikePlus90 = strike + (PI / 2);
        if (strikePlus90 > 2*PI)
            strikePlus90 -= 2*PI;
        
        CGPoint dipPoint1 = CGPointMake((.33) * radius * sin(strikePlus90) + center.x, -(.33) * radius * cos(strikePlus90) + center.y);
        CGPoint dipPoint2 = CGPointMake(-(.33) * radius * sin(strikePlus90) + center.x, (.33) * radius * cos(strikePlus90) + center.y);
        CGPoint givenDipPoint = CGPointMake(radius * sin(dipAngle) + center.x, -radius * cos(dipAngle) + center.y);
        
        CGPoint dipEndPoint = [self closestPointTo:givenDipPoint among:dipPoint1 or:dipPoint2];
        
        //Draw the dip
        [self drawDipWithContext:context from:center to:dipEndPoint withColor:self.color];
        
        //to use the given dip angle (not necessarily perpendicular to the strike) use this
        /*float dipAngle = [self toRadians:self.dip];
        
        CGPoint dipPoint = CGPointMake((.33) * radius * sin(dipAngle) + center.x, -(.33) * radius * cos(dipAngle) + center.y);
        
        [self drawDipWithContext:context from:center to:dipPoint withColor:dipColor];*/
    }
}

@end
