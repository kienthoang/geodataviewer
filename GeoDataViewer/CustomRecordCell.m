//
//  CustomRecordCell.m
//  GeoFieldBook
//
//  Created by excel 2011 on 6/27/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomRecordCell.h"

@implementation CustomRecordCell

@synthesize name = _name;
@synthesize date = _date;
@synthesize time = _time;
@synthesize recordImageView = _recordImageView;
@synthesize type = _type;
@synthesize checkBox = _checkBox;
@synthesize spinner=_spinner;

@synthesize record=_record;

- (void)setRecord:(Record *)record {
    if (record) {
        _record=record;
        
        //show the name, date and time
        self.name.text=[NSString stringWithFormat:@"%@",record.name];
        self.type.text=[record.class description];
        self.date.text=[Record dateFromNSDate:record.date];
        self.time.text = [Record timeFromNSDate:record.date];
        
        //Hide the spinner (in case it's still animating as the cell has been reused)
        self.spinner.hidden=YES;
    }
}

- (void)showCheckBoxAnimated:(BOOL)animated {
    //Only execute if alpha is 0
    if (!self.checkBox.alpha) {
        //Animate if desired
        if (animated) {
            [UIView animateWithDuration:CHECK_BOX_ANIMATION_DURATION animations:^(){
                //move the other views
                for (UIView *view in self.contentView.subviews) {
                    if (view!=self.checkBox)
                        view.transform=CGAffineTransformTranslate(view.transform, self.checkBox.frame.size.width, 0);
                }
                
                //show checkbox
                self.checkBox.alpha=1;
            }];
        } else {
            //Show check box
            self.checkBox.alpha=1;
            
            //move the other views
            for (UIView *view in self.contentView.subviews) {
                if (view!=self.checkBox)
                    view.transform=CGAffineTransformTranslate(view.transform, self.checkBox.frame.size.width, 0);
            }
        }
    }
}

- (void)hideCheckBoxAnimated:(BOOL)animated {
    //Animate if desired
    if (animated) {
        [UIView animateWithDuration:CHECK_BOX_ANIMATION_DURATION animations:^(){
            //move the other views
            for (UIView *view in self.contentView.subviews) {
                if (view!=self.checkBox && !CGAffineTransformIsIdentity(view.transform))
                    view.transform=CGAffineTransformTranslate(view.transform, -self.checkBox.frame.size.width, 0);
            }
            
            //Hide checkbox
            self.checkBox.alpha=0;
        }];
    } else {
        //Hide check box
        self.checkBox.alpha=0;
        
        //move the other views
        for (UIView *view in self.contentView.subviews) {
            if (view!=self.checkBox)
                view.transform=CGAffineTransformTranslate(view.transform, -self.checkBox.frame.size.width, 0);
        }
    }
}

@end
