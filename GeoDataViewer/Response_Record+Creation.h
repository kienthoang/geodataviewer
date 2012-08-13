//
//  Response_Record+Creation.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Response_Record.h"

@interface Response_Record (Creation)

+ (Response_Record *)responseRecordInManagedObjectContext:(NSManagedObjectContext *)context;

@end
