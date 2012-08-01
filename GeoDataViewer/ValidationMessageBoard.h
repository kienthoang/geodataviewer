//
//  ValidationMessageBoard.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/12/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidationMessageBoard : NSObject

- (void)addWarningWithMessage:(NSString *)message;
- (void)addErrorWithMessage:(NSString *)message;

- (int)errorCount;
- (int)warningCount;

- (NSArray *)errorMessages;
- (NSArray *)warningMessages;
- (NSArray *)allMessages;

- (BOOL)anyError;
- (BOOL)anyWarning;

- (void)clearBoard;

@end
