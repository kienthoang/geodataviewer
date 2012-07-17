//
//  MNMobileFunctions.h
//  MindNodeTouchCanvas
//
//  Created by Markus Müller on 15.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>


#pragma -
#pragma Global

#define MNUISelectionColor [UIColor colorWithRed:0.340 green:0.504 blue:0.934 alpha:1.000]
extern CGFloat mnAnimationDuration;
extern CGFloat mnDoubleTapDelay;


#pragma -
#pragma mark CGColor

CGColorRef MNCGColorCreateGenericRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
CGColorRef MNCGColorCreateGenericGray(CGFloat gray, CGFloat alpha);

#pragma mark -
#pragma mark CGRect

CGRect MNCGRectFromPoints(CGPoint point1, CGPoint point2);
CGRect MNCGRectByAddingPoint(CGRect rect, CGPoint point);
CGPoint MNCGRectGetCenterPoint(CGRect rect);
CGRect MNCGRectFromInsetPoint(CGPoint point, CGFloat xInset, CGFloat yInset);
BOOL MNCGRectWithLineIntersectionPoint(CGRect rect, CGPoint a, CGPoint b, CGPoint *intersection);

#pragma mark -
#pragma mark CGContext

void MNCGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat radius);
void MNCGContextSetLineDash(CGContextRef context, NSUInteger style, CGFloat lineWidth);


#pragma mark - CGPath

void CGPathAddRoundedRectToPath(CGMutablePathRef path, CGRect rect, CGFloat radius);


#pragma mark -
#pragma mark Range

#define MNNotFoundRange ((NSRange){NSNotFound, 0})
#define MNZeroRange ((NSRange){0, 0})


#pragma mark -
#pragma mark Points

extern CGPoint MNUndefinedPoint;
CGPoint MNOffsetPoint(CGPoint point, CGFloat x, CGFloat y);
CGPoint MNRoundedPoint(CGPoint point);
CGPoint MNSpacingBetweenPoints(CGPoint point1, CGPoint point2);
CGFloat MNDistanceBetweenPoints(CGPoint point1, CGPoint point2);
CGRect MNValidRect(CGRect rect);
BOOL MNLineIntersectionPoint(CGPoint a, CGPoint b, CGPoint c, CGPoint d, CGPoint *intersection);
CGPoint MNCenterBetweenPoints(CGPoint point1, CGPoint point2);

