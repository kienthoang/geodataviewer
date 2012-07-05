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
    NSString *folderCounter=[folder.records count]>1 ? @"Records" : @"Record";
    self.subtitle.text=[NSString stringWithFormat:@"%d %@",[folder.records count],folderCounter];
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
        [self.delegate folderCell:self userDidSelectDidCheckBoxForRecord:self.folder];
    else
        [self.delegate folderCell:self userDidDeselectDidCheckBoxForRecord:self.folder];
}


- (void)showCheckBoxAnimated:(BOOL)animated {
    //Show check box
    self.checkBox.hidden=NO;
}

- (void)hideCheckBoxAnimated:(BOOL)animated {
    //Hide check box
    self.checkBox.hidden=YES;
}

@end
