//
//  MKCustomAnnotationView.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKCustomAnnotationView.h"

@implementation MKCustomAnnotationView

- (void)reloadAnnotationView {
    [self drawDipStrikeSymbolWithAnnotation:self.annotation];
}

- (void)drawDipStrikeSymbolWithAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Setup the dip strike symbol
        DipStrikeSymbol *symbol=[[DipStrikeSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        Record *record=annotation.record;
        symbol.strike=record.strike.floatValue;
        symbol.dip=record.dip.floatValue;
        symbol.dipDirection=record.dipDirection;
        symbol.backgroundColor=[UIColor clearColor];
        
        //Set the color of the dip strike symbol
        UIColor *color=nil;
        if ([record isKindOfClass:[Bedding class]]) {
            Formation *formation=[(Bedding *)record formation];
            color=[UIColor colorWithRed:formation.redColorComponent.floatValue 
                                  green:formation.greenColorComponent.floatValue 
                                   blue:formation.blueColorComponent.floatValue 
                                  alpha:1.0];
        }
        else if ([record isKindOfClass:[Contact class]]) {
            Formation *upperFormation=[(Contact *)record upperFormation];
            color=[UIColor colorWithRed:upperFormation.redColorComponent.floatValue 
                                  green:upperFormation.greenColorComponent.floatValue 
                                   blue:upperFormation.blueColorComponent.floatValue 
                                  alpha:1.0];
        }
        
        symbol.color=color;
        
        //Add the strike symbol view
        UIGraphicsBeginImageContext(symbol.bounds.size);
        [symbol.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();    
        self.image=image;
    }
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithAnnotation:self.annotation reuseIdentifier:reuseIdentifier])
        [self drawDipStrikeSymbolWithAnnotation:annotation];
    
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    
    [self drawDipStrikeSymbolWithAnnotation:annotation];
}

@end
