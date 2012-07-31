//
//  IEConflictHandlerNotificationNames.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/13/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IEConflictHandlerNotificationNames

#define GeoNotificationConflictHandlerFolderNameConflictOccurs @"ConflictHandler.FolderNameConflictOccurs"
#define GeoNotificationConflictHandlerFormationFolderNameConflictOccurs @"ConflictHandler.FormationFolderNameConflictOccurs"
#define GeoNotificationConflictHandlerImportingDidEnd @"ConflictHandler.ImportingDidEnd"
#define GeoNotificationConflictHandlerImportingWasCanceled @"ConflictHandler.ImportingWasCanceled"

#define GeoNotificationConflictHandlerValidationErrorsOccur @"ConflictHandler.ValidationErrorsOccur"
#define GeoNotificationConflictHandlerValidationLogKey @"ConflictHandler.ValidationLogKey"

@end
