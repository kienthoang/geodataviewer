//
//  MKCustomAnnotationView.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/20/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "MKCustomAnnotationView.h"

#import "SettingManager.h"
#import "ColorManager.h"

#import "Contact+Formation.h"

@implementation MKCustomAnnotationView

- (void)reloadAnnotationView {
    [self drawDipStrikeSymbolWithAnnotation:self.annotation];
}

- (void)drawDipStrikeSymbolWithAnnotation:(MKGeoRecordAnnotation *)annotation {
    if (annotation.record) {
        //Setup the dip strike symbol
        SettingManager *settingManager=[SettingManager standardSettingManager];
        DipStrikeSymbol *symbol=[[DipStrikeSymbol alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        Record *record=annotation.record;
        
        //If the record has dip, strike, dip direciton values, set it up as normal
        //Otherwise - the annotation's record does not have a strike and dip value or its strike and dip value are 0 - set the image only
        if (record.strike && record.dipDirection && record.dip) {
            symbol.strike=record.strike ? record.strike.floatValue : 0.0;
            symbol.dipDirection=record.dipDirection ? record.dipDirection : nil;
            //determine whether or not to show the dip number with the dip strike symbol
            //DONT SHOW IF NO DIP VALUE (different from dip of 0)
            if (settingManager.dipNumberEnabled && record.dip)
                symbol.dip=record.dip.floatValue;
            else
                symbol.dip=-1.0;
        }
        
        //Setup the color of the dip strike symbol if specified by user preference
        UIColor *color=settingManager.defaultSymbolColor;
        if (settingManager.formationColorEnabled && [(id)record formation]) {
            if (![record isKindOfClass:[Other class]]) {
                Formation *formation=[(id)record formation];
                color=[[ColorManager standardColorManager] colorWithName:formation.colorName];
            }
        }
        
        symbol.color=color;
        
        //Add the strike symbol view
        symbol.backgroundColor=[UIColor clearColor];
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
