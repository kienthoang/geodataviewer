//
//  Record+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/3/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"
#import "Folder.h"
#import "Image+Creation.h"

#import "Record+DictionaryKeys.h"
#import "Record+Types.h"

#import "Formation+Creation.h"

#import "Bedding+Creation.h"
#import "Contact+Creation.h"
#import "Fault+Creation.h"
#import "JointSet+Creation.h"

@interface Record (Creation)

+ (Record *)recordForInfo:(NSDictionary *)recordInfo inFolder:(Folder *)folder;

@end
