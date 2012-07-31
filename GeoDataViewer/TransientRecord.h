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
#import "TransientManagedObject.h"

#import "Record.h"

@interface TransientRecord : TransientManagedObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *project;
@property (nonatomic, strong) NSNumber * dip;
@property (nonatomic, strong) NSString * dipDirection;
@property (nonatomic, strong) NSString * fieldOservations;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * strike;
@property (nonatomic, strong) TransientProject *folder;
@property (nonatomic, strong) TransientImage *image; 

#define TransientRecordMinimumDip 0
#define TransientRecordMaximumDip 90
#define TransientRecordMinimumStrike 0
#define TransientRecordMaximumStrike 360
#define TransientRecordMinimumTrend 0
#define TransientRecordMaximumTrend 360
#define TransientRecordMinimumPlunge 0
#define TransientRecordMaximumPlunge 90
#define TransientRecordMinimumLongitude -180
#define TransientRecordMaximumLongitude 180
#define TransientRecordMinimumLatitude -90
#define TransientRecordMaximumLatitude 90

#pragma mark - Setters with validations

- (NSString *)setDipWithValidations:(NSString *)dipString;
- (NSString *)setStrikeWithValidations:(NSString *)strikeString;
- (NSString *)setFieldObservationWithValidations:(NSString *)fieldObservation;
- (NSString *)setDipDirectionWithValidations:(NSString *)dipDirection;
- (NSString *)setLatitudeWithValidations:(NSString *)latitude;
- (NSString *)setLongitudeWithValidations:(NSString *)longitude;

#pragma mark - Convenience methods

+ (TransientRecord *)recordWithType:(NSString *)recordType;

@property (nonatomic,strong) Record *nsManagedRecord;

@end
