//
//  MKMapRecordInfoViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"
#import "Image.h"

@class MKMapRecordInfoViewController;

@protocol MKMapRecordInfoDelegate <NSObject>

- (void)mapRecordInfoViewController:(MKMapRecordInfoViewController *)sender 
 userDidTapOnAccessoryViewForRecord:(Record *)record;

@end

@interface MKMapRecordInfoViewController : UIViewController

@property (nonatomic,strong) Record *record;

@property (nonatomic,weak) id <MKMapRecordInfoDelegate> delegate;

@end
