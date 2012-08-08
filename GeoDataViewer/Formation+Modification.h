//
//  Formation+Modification.h
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/8/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Formation.h"

#import "Formation_Folder.h"
#import "Formation+DictionaryKeys.h"

#import "TextInputFilter.h"

@interface Formation (Modification)

- (BOOL)updateFormationWithFormationInfo:(NSDictionary *)formationInfo;

@end
