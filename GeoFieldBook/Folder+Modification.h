//
//  Folder+Modification.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Folder.h"

@interface Folder (Modification)

- (BOOL)changeFolderNameTo:(NSString *)newName;  //return true if the name change was successful

@end
