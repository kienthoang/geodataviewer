//
//  Formation_Folder+Modification.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation_Folder.h"

@interface Formation_Folder (Modification)

- (BOOL)changeFormationFolderNameTo:(NSString *)newName;  //return true if the name change was successful

@end
