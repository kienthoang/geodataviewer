//
//  ModalFolderViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Folder.h"
#import "Folder+DictionaryKeys.h"

@class ModalFolderViewController;

@protocol ModalFolderDelegate <NSObject>

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
            obtainedNewFolderInfo:(NSDictionary *)folderInfo;

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
             didAskToModifyFolder:(Folder *)folder
       obtainedModifiedFolderInfo:(NSDictionary *)folderInfo;

@end

@interface ModalFolderViewController : UIViewController

@property (nonatomic,strong) Folder *folder;    //The name of the folder
@property (nonatomic,weak) id <ModalFolderDelegate> delegate;

@end
