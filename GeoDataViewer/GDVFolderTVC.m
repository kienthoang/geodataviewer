//
//  GDVFolderTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVFolderTVC.h"

@interface GDVFolderTVC ()

@property (nonatomic,weak) SSLoadingView *loadingView;

@end

@implementation GDVFolderTVC

@synthesize loadingView=_loadingView;

@synthesize studentGroup=_studentGroup;
@synthesize folders=_folders;

- (void)showLoadingScreen {
    if (!self.loadingView) {
        CGSize size = self.view.frame.size;
        
        SSLoadingView *loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        [self.view addSubview:loadingView];
        self.loadingView=loadingView;
    }
}

- (void)stopLoadingScreen {
    if (self.loadingView)
        [self.loadingView removeFromSuperview];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Folder Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    Folder *folder=[self.folders objectAtIndex:indexPath.row];
    cell.textLabel.text=folder.folderName;
    int numRecords=folder.records.count;
    NSString *recordCounter=numRecords>1 ?[NSString stringWithFormat:@"%d Records",numRecords] : [NSString stringWithFormat:@"%d Record",numRecords];
    cell.detailTextLabel.text=recordCounter;
    
    return cell;
}

@end
