//
//  ExportDoubleTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "UIDoubleTableViewController.h"

@protocol ExportButtonOwner

- (void)needsUpdateExportButtonForNumberOfSelectedItems:(int)count;

@end

@interface ExportDoubleTableViewController : UIDoubleTableViewController <ExportButtonOwner>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *exportButton;

@end
