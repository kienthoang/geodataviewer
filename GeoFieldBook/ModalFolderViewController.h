//
//  ModalFolderViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalFolderViewController;

@protocol ModalFolderDelegate <NSObject>

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
            obtainedNewFolderName:(NSString *)folderName;

- (void)modalFolderViewController:(ModalFolderViewController *)sender 
         didAskToModifyFolderName:(NSString *)originalName 
       obtainedModifiedFolderName:(NSString *)folderName;

@end

@interface ModalFolderViewController : UIViewController

@property (nonatomic,strong) NSString *folderName;    //The name of the folder
@property (nonatomic,weak) id <ModalFolderDelegate> delegate;

@end
