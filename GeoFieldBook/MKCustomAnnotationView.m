//
//  MKCustomAnnotationView.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKCustomAnnotationView.h"

@implementation MKCustomAnnotationView

- (void)drawDipStrikeSymbolWithAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Setup the dip stirke symbol
        DipStrikeSymbol *symbol=[[DipStrikeSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        Record *record=annotation.record;
        symbol.strike=record.strike.floatValue;
        symbol.dip=record.dip.floatValue;
        symbol.dipDirection=record.dipDirection;
        
        //Add the strike symbol view
        symbol.backgroundColor=[UIColor clearColor];
        [self addSubview:symbol];
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
