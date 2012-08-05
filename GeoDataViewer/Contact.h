//
//  Contact.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Record.h"

@class Formation;

@interface Contact : Record

@property (nonatomic, retain) Formation *lowerFormation;
@property (nonatomic, retain) Formation *upperFormation;

@end
