//
//  CustomFolderCell.m
//  GeoFieldBook
//
//  Created by excel 2011 on 7/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CustomFolderCell.h"
#import "CheckBox.h"

@implementation CustomFolderCell

@synthesize title=_title;
@synthesize subtitle=_subtitle;
@synthesize checkBox=_checkBox;

@synthesize folder=_folder;

@synthesize delegate=_delegate;

- (void)setFolder:(Folder *)folder {
    _folder=folder;
    
    //Setup the title and subtitle of the cell
    self.title.text=folder.folderName;
    NSString *recordCounter=[folder.records count]>1 ? @"Records" : @"Record";
    self.subtitle.text=[NSString stringWithFormat:@"%d %@",[folder.records count],recordCounter];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //Add gesture recognizer to the checkbox
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] 
                                   initWithTarget:self action:@selector(toggleCheckbox:)];
    [self.checkBox addGestureRecognizer:tgr];
}

-(void)toggleCheckbox:(UITapGestureRecognizer *)tgr {
    //Toggle the state of the checkbox
    CheckBox *checkbox=(CheckBox *)self.checkBox;
    checkbox.isChecked=!checkbox.isChecked;
    checkbox.image = checkbox.isChecked ? checkbox.checked : checkbox.unchecked; 
        
    //Notify the delegate
    if (checkbox.isChecked)
        [self.delegate folderCell:self userDidSelectDidCheckBoxForFolder:self.folder];
    else
        [self.delegate folderCell:self userDidDeselectDidCheckBoxForFolder:self.folder];
}


- (void)showCheckBoxAnimated:(BOOL)animated {
    //Only execute if alpha is 0
    if (!self.checkBox.alpha) {
        //Animate if desired
        if (animated) {
            [UIView animateWithDuration:CHECK_BOX_ANIMATION_DURATION animations:^(){
                //move the title and subtitle
                self.title.transform=CGAffineTransformTranslate(self.title.transform, self.checkBox.frame.size.width, 0);
                self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, self.checkBox.frame.size.width, 0);
                
                //show checkbox
                self.checkBox.alpha=1;
            }];
        } else {
            //Show check box
            self.checkBox.alpha=1;
            
            //move the title and subtitle
            self.title.transform=CGAffineTransformTranslate(self.title.transform, self.checkBox.frame.size.width, 0);
            self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, self.checkBox.frame.size.width, 0);
        }
    }
}

- (void)hideCheckBoxAnimated:(BOOL)animated {
    //Animate if desired
    if (animated) {
        [UIView animateWithDuration:CHECK_BOX_ANIMATION_DURATION animations:^(){
            //Move the title and subtitle only if they are not in their original positions (before checkbox is showed) 
            if (!CGAffineTransformIsIdentity(self.title.transform))
                self.title.transform=CGAffineTransformTranslate(self.title.transform, -self.checkBox.frame.size.width, 0);
            if (!CGAffineTransformIsIdentity(self.subtitle.transform))
                self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, -self.checkBox.frame.size.width, 0);
            
            //Hide the checkbox
            self.checkBox.alpha=0;
        }];
    } else {
        //Hide the checkbox
        self.checkBox.alpha=0;
        
        //Move the title and subtitle only if they are not in their original positions (before checkbox is showed) 
        if (!CGAffineTransformIsIdentity(self.title.transform))
            self.title.transform=CGAffineTransformTranslate(self.title.transform, -self.checkBox.frame.size.width, 0);
        if (!CGAffineTransformIsIdentity(self.subtitle.transform))
            self.subtitle.transform=CGAffineTransformTranslate(self.subtitle.transform, -self.checkBox.frame.size.width, 0);
    }
}

@end
