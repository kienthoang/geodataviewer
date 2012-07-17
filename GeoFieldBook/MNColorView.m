//
//  MNColorView.m
//  MNColorPicker
//

#import "MNColorView.h"
#import "MNMobileFunctions.h"

@interface MNColorView ()

@property (nonatomic, assign) CAShapeLayer *touchDownLayer;
@property (nonatomic, assign) CALayer *checkmarkLayer;
+ (CGPathRef)createPathForBorderStyle:(MNColorViewBorderStyle)borderStyle boundingRect:(CGRect)rect;

@end

static NSUInteger cornerRadius = 6.0f;
static NSUInteger inset = 1.0f;
static CGFloat kCheckmarkWidth = 22;


// KVO
static NSString *MNColorViewColorKey = @"color";
static NSString *MNColorViewRedrawKey = @"redraw";
static NSString *MNColorViewRedrawObservationContext = @"MNColorViewRedrawObservationContext";


@implementation MNColorView

#pragma mark - Properties

@synthesize color=_color;
@synthesize borderStyle=_borderStyle;
@synthesize touchDownLayer=_touchDownLayer;
@synthesize checkmarkLayer=_checkmarkLayer;


#pragma mark - Init


+ (id)colorViewWithColor:(UIColor *)color borderStyle:(MNColorViewBorderStyle)borderStyle
{
    MNColorView *control = [[[self class] alloc] initWithFrame:CGRectZero];
    
    control.color = color;
    control.borderStyle = borderStyle;
    
    return [control autorelease];
}


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.color = [UIColor blackColor];
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.color = [UIColor whiteColor];
    
    self.touchDownLayer = [CAShapeLayer layer];
    self.touchDownLayer.opacity = 0.0f;
    [self.layer addSublayer:self.touchDownLayer];
    
    self.checkmarkLayer = [CALayer layer];
    self.checkmarkLayer.hidden = YES;
    self.checkmarkLayer.contents = (id)[UIImage imageNamed:@"MNColorViewCheckmark.png"].CGImage;
    self.checkmarkLayer.bounds = CGRectMake(0, 0, kCheckmarkWidth, kCheckmarkWidth);
    [self.layer addSublayer:self.checkmarkLayer];

    [self addObserver:self forKeyPath:MNColorViewRedrawKey options:0 context:MNColorViewRedrawObservationContext];
    
    return self;
}


- (void)dealloc 
{
    [self removeObserver:self forKeyPath:MNColorViewRedrawKey];
    
    MNRelease(_color);
    [super dealloc];
}

#pragma mark - Custom Properties

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkmarkLayer.hidden = !selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (animated) {
        [self setSelected:selected];
    } else {
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.000f] forKey:kCATransactionAnimationDuration];
        [self setSelected:selected];
        [CATransaction commit];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGColorRef color = self.color.CGColor;
    MNColorViewBorderStyle borderStyle = self.borderStyle;
    rect = CGRectInset(rect, 0.5, 0.5);
        
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, color);
    CGColorRef strokeColor = MNCGColorCreateGenericGray(0.6f, 1.0f);
    CGContextSetStrokeColorWithColor(c, strokeColor);
    CGColorRelease(strokeColor);
    CGContextSetLineWidth(c, 1);
    
    CGPathRef path = [[self class] createPathForBorderStyle:self.borderStyle boundingRect:self.bounds];
    CGContextAddPath(c, path);
    CGContextDrawPath(c, kCGPathFill);
    CGPathRelease(path);
    
    CGContextSetBlendMode(c, kCGBlendModeMultiply);
    
    
    CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
    CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;

    minx = minx + inset;
    maxx = maxx - inset;

    if (borderStyle == MNColorViewBorderStyleSingle) {
        miny = miny + inset;        
        maxy = maxy - inset;

        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, cornerRadius);
        CGContextAddArcToPoint(c, maxx, miny, maxx, midy, cornerRadius);
        CGContextAddLineToPoint(c, maxx, midy);
        CGContextDrawPath(c, kCGPathStroke);
        
        CGContextMoveToPoint(c, minx, midy);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, cornerRadius);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, midy, cornerRadius);
        CGContextAddLineToPoint(c, maxx, midy);
        CGContextSetShadowWithColor(c, CGSizeMake(0, 1.5), 0,[[UIColor whiteColor] colorWithAlphaComponent:0.8f].CGColor); 
        CGContextDrawPath(c, kCGPathStroke);
    } else if (borderStyle == MNColorViewBorderStyleTop) {
        miny = miny + inset;        
        maxy = maxy + inset;

        CGContextMoveToPoint(c, minx, maxy);
        CGContextAddArcToPoint(c, minx, miny, midx, miny, cornerRadius);
        CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, cornerRadius);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextDrawPath(c, kCGPathStroke);
    } else if (borderStyle == MNColorViewBorderStyleBottom) {
        miny = miny - inset;        
        maxy = maxy - inset;
        CGContextMoveToPoint(c, minx, miny);
        CGContextAddArcToPoint(c, minx, maxy, midx, maxy, cornerRadius);
        CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, cornerRadius);
        CGContextAddLineToPoint(c, maxx, miny);
        CGContextSetShadowWithColor(c, CGSizeMake(0, 1.5), 0,[[UIColor whiteColor] colorWithAlphaComponent:0.8f].CGColor); 
        CGContextDrawPath(c, kCGPathStroke);
    } else if (borderStyle == MNColorViewBorderStyleMiddle) {
        miny = miny - inset;        
        maxy = maxy + inset;

        CGContextMoveToPoint(c, minx, miny);
        CGContextAddLineToPoint(c, minx, maxy);
        CGContextMoveToPoint(c, maxx, miny);
        CGContextAddLineToPoint(c, maxx, maxy);
        CGContextSetShadowWithColor(c, CGSizeMake(0, 1.5), 0,[[UIColor whiteColor] colorWithAlphaComponent:0.8f].CGColor); 
        CGContextDrawPath(c, kCGPathStroke);
    }
    CGContextSetBlendMode(c, kCGBlendModeNormal);

}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    CGPathRef path = [[self class] createPathForBorderStyle:self.borderStyle boundingRect:self.bounds];
    self.touchDownLayer.path = path;
    CGPathRelease(path);
    
    
    CGRect frame = self.bounds;
    self.checkmarkLayer.position = CGPointMake(CGRectGetMaxX(frame)-kCheckmarkWidth/2-4,CGRectGetMaxY(frame)-kCheckmarkWidth/2-4);

}

#pragma mark - Touch Handling

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL flag = [super beginTrackingWithTouch:touch withEvent:event];
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.001f] forKey:kCATransactionAnimationDuration];
    self.touchDownLayer.opacity = 0.2f;
    [CATransaction commit];

    return flag;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchDownLayer.opacity = 0.0;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.touchDownLayer.opacity = 0.0;
    [super cancelTrackingWithEvent:event];
}


+ (CGPathRef)createPathForBorderStyle:(MNColorViewBorderStyle)borderStyle boundingRect:(CGRect)rect
{
    // Drawing code in parts from http://stackoverflow.com/questions/400965/how-to-customize-the-background-border-colors-of-a-grouped-table-view
//    rect = CGRectInset(rect, 0.5, 0.5);
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (borderStyle == MNColorViewBorderStyleTop) {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + inset;
        miny = roundf(miny + inset);
        
        maxx = maxx - inset;
        maxy = maxy - inset;
        
        CGPathMoveToPoint(path, NULL, minx, maxy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, cornerRadius);
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
    } else if (borderStyle == MNColorViewBorderStyleBottom) {
        
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + inset;
        miny = miny + inset;
        
        maxx = maxx - inset;
        maxy = roundf(maxy - inset);
        
        CGPathMoveToPoint(path, NULL, minx, miny);
        CGPathAddArcToPoint(path, NULL, minx, maxy, midx, maxy, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx, miny, cornerRadius);
        CGPathAddLineToPoint(path, NULL, maxx, miny);
    } else if (borderStyle == MNColorViewBorderStyleMiddle) {
        CGFloat minx = CGRectGetMinX(rect) , maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + inset;
        miny = roundf(miny + inset);
        
        maxx = maxx - inset;
        maxy = roundf(maxy - inset);
        
        CGPathMoveToPoint(path, NULL, minx, miny);
        CGPathAddLineToPoint(path, NULL, maxx, miny);
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
        CGPathAddLineToPoint(path, NULL, minx, maxy);
    } else if (borderStyle == MNColorViewBorderStyleSingle) {
        CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
        CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
        minx = minx + inset;
        miny = miny + inset;
        
        maxx = maxx - inset;
        maxy = maxy - inset;
                
        CGPathMoveToPoint(path, NULL, minx, midy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
        CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    }
    return path;
}


#pragma mark - Observing

+ (NSSet *)keyPathsForValuesAffectingRedraw 
{
    return [NSSet setWithObject:MNColorViewColorKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if (context == MNColorViewRedrawObservationContext) {
        [self setNeedsDisplay];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
