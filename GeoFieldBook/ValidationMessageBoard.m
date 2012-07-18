//
//  ValidationMessageBoard.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/12/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ValidationMessageBoard.h"

@interface ValidationMessageBoard()

@property (nonatomic,strong) NSArray *warnings;
@property (nonatomic,strong) NSArray *errors;

@end

@implementation ValidationMessageBoard

@synthesize warnings=_warnings;
@synthesize errors=_errors;

#pragma mark - Getters and Setters

- (NSArray *)warnings {
    if (!_warnings)
        _warnings=[NSArray array];
    
    return _warnings;
}

- (NSArray *)errors {
    if (!_errors)
        _errors=[NSArray array];
    
    return _errors;
}

#pragma mark - Public API

- (void)addWarningWithMessage:(NSString *)message {
    //Add the error to the error list
    if (![self.warnings containsObject:message]) {
        NSMutableArray *warnings=[self.warnings mutableCopy];
        [warnings addObject:message];
        self.warnings=[warnings copy];
    }
}

- (void)addErrorWithMessage:(NSString *)message {
    if (![self.errors containsObject:message]) {
    //Add the error to the error list
        NSMutableArray *errors=[self.errors mutableCopy];
        [errors addObject:message];
        self.errors=[errors copy];
    }
}

- (int)errorCount {
    return self.errors.count;
}

- (int)warningCount {
    return self.warnings.count;
}

- (NSArray *)errorMessages {
    return self.errors;
}

- (NSArray *)warningMessages {
    return self.warnings;
}

- (NSArray *)allMessages {
    NSMutableArray *allMessages=[NSMutableArray arrayWithArray:self.errorMessages];
    [allMessages addObjectsFromArray:self.warningMessages];
    return [allMessages copy];
}

- (BOOL)anyError {
    return self.errorMessages.count>0;
}

- (BOOL)anyWarning {
    return self.warningMessages.count>0;
}

- (void)clearBoard {
    self.errors=[NSArray array];
    self.warnings=[NSArray array];
}

@end
