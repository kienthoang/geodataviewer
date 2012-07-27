//
//  CustomFormationCell.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomFormationCell.h"

#import "ColorManager.h"

@implementation CustomFormationCell

@synthesize formation=_formation;
@synthesize colorPatch=_colorPatch;
@synthesize name=_name;

- (UIColor *)colorForFormation:(Formation *)formation {
    UIColor *formationColor=[[ColorManager standardColorManager] colorWithName:formation.colorName];
    
    return formationColor;
}

- (void)setColorPatch:(UIButton *)colorPatch {
    //Setup the color patch
    _colorPatch=colorPatch;
    self.colorPatch.layer.borderColor=[UIColor blackColor].CGColor;
    self.colorPatch.layer.cornerRadius=8.0f;
    self.colorPatch.layer.borderWidth=1.0f;
}

- (void)setFormation:(Formation *)formation {
    _formation=formation;
    
    //Redraw the color patch
    self.colorPatch.backgroundColor=[self colorForFormation:formation];
    
    //Set the name
    self.name.text=formation.formationName;
}

//Override set Selected to be sure the color patch's background color does not get covered by the cell's selected state background color
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.colorPatch.backgroundColor=[self colorForFormation:self.formation];
}

@end
