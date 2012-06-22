//
//  ModalRecordTypeSelector.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ModalRecordTypeSelector;

@protocol ModalRecordTypeSelectorDelegate <NSObject>

- (void)modalRecordTypeSelector:(ModalRecordTypeSelector *)sender 
          userDidPickRecordType:(NSString *)type;

@end

@interface ModalRecordTypeSelector : UIViewController

@property (nonatomic,weak) id <ModalRecordTypeSelectorDelegate> delegate;
@property (nonatomic,strong) NSArray *recordTypes;   //array of NSStrings representing record types

@end
