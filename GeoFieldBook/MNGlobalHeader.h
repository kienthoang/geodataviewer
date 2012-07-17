//
//  MNGlobalHeader.h
//  MindNodeTouchCanvas
//
//  Created by Markus Müller on 15.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#pragma -
#pragma Global

#if MNDebug
#define MNRelease(object) [object release];
#else
#define MNRelease(object) [object release], object=nil;
#endif

