//
//  DipDirectionPickerViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PickerViewController.h"

@class DipDirectionPickerViewController;

@protocol DipDirectionPickerDelegate <NSObject>

- (void)dipDirectionPickerViewController:(DipDirectionPickerViewController *)sender 
          userDidSelectDipDirectionValue:(NSString *)dipDirection;

@end

@interface DipDirectionPickerViewController : PickerViewController

@property (nonatomic,weak) id <DipDirectionPickerDelegate> delegate;

@end
