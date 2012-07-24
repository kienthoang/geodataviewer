//
//  Question.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * prompt;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;

@end
