//
//  CustomStudentGroupCell.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomStudentGroupCell.h"



@implementation CustomStudentGroupCell

@synthesize studentGroup=_studentGroup;

@synthesize colorPatch=_colorPatch;
@synthesize name=_name;

@synthesize groupID = _groupID;

@synthesize delegate=_delegate;

- (IBAction)colorPatchPressed:(UIButton *)sender
{
    [self.delegate colorPatchPressedWithColorRGB:sender.backgroundColor andSender:self];
}

- (UIColor *)colorForStudentGroup:(Group *)group {
    double redComponent=group.redComponent.doubleValue;
    double greenComponent=group.greenComponent.doubleValue;
    double blueComponent=group.blueComponent.doubleValue;
    
    return [UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:1.0];
}

- (void)setColorPatch:(UIButton *)colorPatch {
    //Setup the color patch
    _colorPatch=colorPatch;
    self.colorPatch.layer.borderColor=[UIColor blackColor].CGColor;
    self.colorPatch.layer.cornerRadius=8.0f;
    self.colorPatch.layer.borderWidth=1.0f;
}

- (void)setStudentGroup:(Group *)studentGroup {
    _studentGroup=studentGroup;    
    //Redraw the color patch
    self.colorPatch.backgroundColor=[self colorForStudentGroup:studentGroup];    
    //Set the name
    self.name.text=studentGroup.name;       
    //set the group id
    self.groupID.text = studentGroup.identifier;
}

//Override set Selected to be sure the color patch's background color does not get covered by the cell's selected state background color
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.colorPatch.backgroundColor=[self colorForStudentGroup:self.studentGroup];
}

-(void) updatePatchColor:(UIColor *) color {
    self.colorPatch.backgroundColor = color;
    
}

@end
