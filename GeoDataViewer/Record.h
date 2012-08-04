//
//  Record.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Folder, Image;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * dip;
@property (nonatomic, retain) NSString * dipDirection;
@property (nonatomic, retain) NSString * fieldObservations;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * strike;
@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) Image *image;

@end
