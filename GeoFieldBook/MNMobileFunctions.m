//
//  MNMobileFunctions.m
//  MindNodeTouchCanvas
//
//  Created by Markus M√ºller on 15.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MNMobileFunctions.h"


#pragma -
#pragma Global

CGFloat mnAnimationDuration = 0.25f;
CGFloat mnDoubleTapDelay = 0.35f;

#pragma mark -
#pragma mark CGColor

CGColorRef MNCGColorCreateGenericRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) 
{
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	const CGFloat components[] = {red, green, blue, alpha};
	CGColorRef colorRef = CGColorCreate(space, components);
	CGColorSpaceRelease(space);
	return colorRef;
}


CGColorRef MNCGColorCreateGenericGray(CGFloat gray, CGFloat alpha) 
{
	CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
	const CGFloat components[] = {gray, alpha};
	CGColorRef colorRef = CGColorCreate(space, components);
	CGColorSpaceRelease(space);
	return colorRef;
}


#pragma mark -
#pragma mark CGRect


CGRect MNCGRectFromPoints(CGPoint point1, CGPoint point2) 
{	
	CGRect result = CGRectZero;
	if (point1.x < point2.x) {
		result.origin.x = point1.x;
		result.size.width = point2.x - point1.x;
	} else {
		result.origin.x = point2.x;
		result.size.width = point1.x - point2.x;
	}
	
	if (point1.y < point2.y) {
		result.origin.y = point1.y;
		result.size.height = point2.y - point1.y;
	} else {
		result.origin.y = point2.y;
		result.size.height = point1.y - point2.y;
	}
	
	return result;
}

CGRect MNCGRectByAddingPoint(CGRect rect, CGPoint point)
{
	if (point.x > CGRectGetMaxX(rect)) {
		rect.size.width = point.x - CGRectGetMinX(rect);
	} else if (point.x < CGRectGetMinX(rect)) {
		rect.size.width = CGRectGetMaxX(rect) - point.x;
		rect.origin.x = point.x;
	} // no need for else, point.x is already in rect
	
	if (point.y > CGRectGetMaxY(rect)) {
		rect.size.height = point.y - CGRectGetMinY(rect);
	} else if (point.y < CGRectGetMinY(rect)) {
		rect.size.height = CGRectGetMaxY(rect) - point.y;
		rect.origin.y = point.y;
	} // no need for else, point.y is already in rect
    
	return rect;
    
}


CGPoint MNCGRectGetCenterPoint(CGRect rect)
{
	CGPoint point;
	point.x = CGRectGetMidX(rect);
	point.y = CGRectGetMidY(rect);
	return point;
}


CGRect MNCGRectFromInsetPoint(CGPoint point, CGFloat xInset, CGFloat yInset)
{
	CGRect rect;
	rect.origin.x = point.x - xInset;
	rect.origin.y = point.y - yInset;
	rect.size.width = xInset * 2;
	rect.size.height = yInset * 2;
	return rect;
}


BOOL MNCGRectWithLineIntersectionPoint(CGRect rect, CGPoint a, CGPoint b, CGPoint *intersection) 
{
    // top
    CGPoint c = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint d = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    if (MNLineIntersectionPoint(a, b, c, d, intersection)) return YES;
    
    // bottom
    c = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    d = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    if (MNLineIntersectionPoint(a, b, c, d, intersection)) return YES;
    
    // left
    c = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    d = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    if (MNLineIntersectionPoint(a, b, c, d, intersection)) return YES;
    
    // right
    c = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    d = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    if (MNLineIntersectionPoint(a, b, c, d, intersection)) return YES;
    
    return NO;
}



#pragma mark -
#pragma mark CGContext Extensions

void MNCGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat radius) 
{
	// code based on Apple's QuartzDemo Sample
	
	// verify that your radius is no more than half the width and height of your rectangle
	CGFloat width = CGRectGetWidth(rect);
    if (radius > width/2.0) {
        radius = width/2.0;
	}
	
	CGFloat height = CGRectGetHeight(rect);
    if (radius > height/2.0) {
        radius = height/2.0; 
	}
    
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
}


void MNCGContextSetLineDash(CGContextRef context, NSUInteger style, CGFloat lineWidth)
{
	CGFloat dashArray[2];
	switch (style) {
		case 0: 
		{
			CGContextSetLineDash(context, 0.0, dashArray, 0);			
			break;
		}
		case 1:
		{
			dashArray[0] = 2*lineWidth;
			dashArray[1] = 2*lineWidth;
			CGContextSetLineDash(context, 0.0, dashArray, 2);
			break;
		}
		case 2:
		{
			dashArray[0] = 5*lineWidth;
			dashArray[1] = 5*lineWidth;
			CGContextSetLineDash(context, 0.0, dashArray, 2);
			break;
		}
		case 3:
		{
			dashArray[0] = 5*lineWidth;
			dashArray[1] = 2*lineWidth;
			CGContextSetLineDash(context, 0.0, dashArray, 2);
			break;
		}
		case 4:
		{
			dashArray[0] = 1*lineWidth;
			dashArray[1] = 1*lineWidth;
			CGContextSetLineDash(context, 0.0, dashArray, 2);
			break;
		}
	}
}

#pragma mark - CGPath

void CGPathAddRoundedRectToPath(CGMutablePathRef path, CGRect rect, CGFloat radius)
{
	// verify that your radius is no more than half the width and height of your rectangle
	CGFloat width = CGRectGetWidth(rect);
    if (radius > width/2.0) {
        radius = width/2.0;
	}
	
	CGFloat height = CGRectGetHeight(rect);
    if (radius > height/2.0) {
        radius = height/2.0; 
	}
    
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
	CGPathMoveToPoint(path, NULL, minx, midy);
	CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, radius);
	CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, radius);
	CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, radius);
	CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, radius);
	CGPathCloseSubpath(path);

}


#pragma mark -
#pragma mark Points

CGPoint MNUndefinedPoint = {FLT_MAX,FLT_MAX};


CGPoint MNOffsetPoint(CGPoint point, CGFloat x, CGFloat y) 
{
	return CGPointMake(point.x + x, point.y + y);
}


CGPoint MNRoundedPoint(CGPoint point) 
{
	return CGPointMake(round(point.x), round(point.y));
}


CGPoint MNSpacingBetweenPoints(CGPoint point1, CGPoint point2) 
{
	return CGPointMake(point2.x-point1.x, point2.y-point1.y);
}

CGFloat MNDistanceBetweenPoints(CGPoint point1, CGPoint point2) 
{
	CGFloat dx = point1.x - point2.x;
	CGFloat dy = point1.y - point2.y;
	return sqrt (dx * dx + dy * dy);
}

CGPoint MNCenterBetweenPoints(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + (point2.x-point1.x) / 2.0, point1.y + (point2.y-point1.y) / 2.0);
}


CGRect MNValidRect(CGRect rect) 
{
	if (rect.size.width < 0) {
		rect.origin.x += rect.size.width;
		rect.size.width = 0.0f - rect.size.width;
	}
	if (rect.size.height < 0) {
		rect.origin.y += rect.size.height;
		rect.size.height *= -1;
	}
	return rect;
}




BOOL MNLineIntersectionPoint(CGPoint a, CGPoint b, CGPoint c, CGPoint d, CGPoint *intersection) 
{
    //  public domain function b.y Darel Rex Finley, 2006
    // http://alienryderflex.com/intersect/
    
    CGFloat  distAB, theCos, theSin, newX, ABpos ;
    
    //  Fail if either line segment is zero-length.
    if (((a.x==b.x) && (a.y==b.y)) || ((c.x==d.x) && (c.y==d.y))) return NO;
    
    //  Fail if the segments share an end-point.
    if (((a.x==c.x) && (a.y==c.y)) || ((b.x==c.x && b.y==c.y)) ||  ((a.x==d.x) && (a.y==d.y)) || ((b.x==d.x) && (b.y==d.y))) {
        return NO; 
    }
    
    //  (1) Translate the system so that point A is on the origin.
    b.x-=a.x; b.y-=a.y;
    c.x-=a.x; c.y-=a.y;
    d.x-=a.x; d.y-=a.y;
    
    //  Discover the length of segment A-B.
    distAB=sqrt(b.x*b.x+b.y*b.y);
    
    //  (2) Rotate the system so that point B is on the positive X a.xis.
    theCos=b.x/distAB;
    theSin=b.y/distAB;
    newX=c.x*theCos+c.y*theSin;
    c.y  =c.y*theCos-c.x*theSin; c.x=newX;
    newX=d.x*theCos+d.y*theSin;
    d.y  =d.y*theCos-d.x*theSin; d.x=newX;
    
    //  Fail if segment C-D doesn't cross line A-B.
    if ((c.y<0. && d.y<0.) || (c.y>=0. && d.y>=0.)) return NO;
    
    //  (3) Discover the position of the intersection point along line A-B.
    ABpos=d.x+(c.x-d.x)*d.y/(d.y-c.y);
    
    //  Fail if segment C-D crosses line A-B outside of segment A-B.
    if (ABpos<0. || ABpos>distAB) return NO;
    
    //  (4) Apply the discovered position to line A-B in the original coordinate system.
    (*intersection).x=a.x+ABpos*theCos;
    (*intersection).y=a.y+ABpos*theSin;
    
    //  Success.
    return YES; 
}


