//
//  TransientRecord.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransientImage.h"
#import "TransientProject.h"

@interface TransientRecord : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *project;
@property (nonatomic, strong) NSString * dateString;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSNumber * dip;
@property (nonatomic, strong) NSString * dipDirection;
@property (nonatomic, strong) NSString * fieldOservations;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * strike;
@property (nonatomic, strong) TransientProject *folder;
@property (nonatomic, strong) TransientImage *image; 

-(BOOL) validateDate:(NSDate *)date;
-(BOOL) validateDip:(NSNumber *)dip;
-(BOOL) validateStrike:(NSNumber *)strike;
-(BOOL) validateDipDirection:(NSString *)dipDirection;

@end
