//
//  ImportTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/10/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ImportTableViewController.h"
#import "IEEngine.h"
#import "ConflictHandler.h"
#import "GeoDatabaseManager.h"

@interface ImportTableViewController() <UIActionSheetDelegate>

@property (nonatomic,strong) UILabel *sectionFooter;
@property (nonatomic,strong) UIBarButtonItem *hiddenButton;

@property (nonatomic,strong) UIView * headerView;

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * bottomView;

@property (nonatomic,strong) UILabel * topLabel;
@property (nonatomic,strong) UILabel * bottomLabel;

@property (nonatomic) BOOL refreshing;

@end

@implementation ImportTableViewController

@synthesize csvFileNames=_csvFileNames;
@synthesize selectedCSVFiles=_selectedCSVFiles;

@synthesize sectionFooter=_sectionFooter;
@synthesize importButton = _importButton;

@synthesize engine=_engine;
@synthesize conflictHandler=_conflictHandler;

@synthesize deleteButton=_deleteButton;
@synthesize addButton=_addButton;
@synthesize hiddenButton=_hiddenButton;

@synthesize headerView=_headerView;
@synthesize topView=_topView;
@synthesize bottomView=_bottomView;
@synthesize topLabel=_topLabel;
@synthesize bottomLabel=_bottomLabel;
@synthesize refreshing=_refreshing;

@synthesize csvFileExtension=_csvFileExtension;

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

#pragma mark - Initial Setups

- (void)synchronizeWithFileSystem {
    //Get the list of csv files from the document directories
    NSMutableArray *csvFileNames=[NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *urls=[fileManager contentsOfDirectoryAtPath:[documentDirURL path] error:NULL];
    for (NSURL *url in urls) {
        //If the file name has the required extension, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:self.csvFileExtension])
            [csvFileNames addObject:fileName];
    }
    
    self.csvFileNames=csvFileNames;
}

#pragma mark - Getters and Setters

- (void)setCsvFileNames:(NSArray *)csvFileNames {
    if (![_csvFileNames isEqualToArray:csvFileNames]) {
        _csvFileNames=csvFileNames;
        
        //Reload table
        [self.tableView reloadData];
    }
}

- (NSArray *)selectedCSVFiles {
    if (!_selectedCSVFiles)
        _selectedCSVFiles=[NSArray array];
    
    return _selectedCSVFiles;
}

- (void)setSelectedCSVFiles:(NSArray *)selectedCSVFiles {
    _selectedCSVFiles=selectedCSVFiles;
    
    //Update the section footers
    int numOfFiles=[self.selectedCSVFiles count];
    NSString *fileCounter=numOfFiles>1 ? @"files" : @"file";
    self.sectionFooter.text=numOfFiles ? [NSString stringWithFormat:@"%d %@ selected.",numOfFiles,fileCounter] : @"No file selected.";
    
    //Update the buttons accordingly
    [self updateButtons];
}

- (NSString *)csvFileExtension {
    if (!_csvFileExtension)
        self.csvFileExtension=@".csv";
    
    return _csvFileExtension;
}

#pragma mark - UI Updaters

- (void)updateButtons {
    int numFiles=self.selectedCSVFiles.count;
    
    //Update the import button
    self.importButton.title=numFiles ? [NSString stringWithFormat:@"Import (%d)",numFiles] : @"Import";
    self.importButton.enabled=numFiles>0;
    
    //Update the delete button
    self.deleteButton.title=numFiles ? [NSString stringWithFormat:@"Delete (%d)",numFiles] : @"Delete";
    self.deleteButton.enabled=numFiles>0;
}

#pragma mark - Target-Action Handlers

- (IBAction)deletePressed:(UIBarButtonItem *)sender {
    int numOfDeletedFolders=self.selectedCSVFiles.count;
    NSString *message=numOfDeletedFolders > 1 ? [NSString stringWithFormat:@"Are you sure you want to delete %d csv files?",numOfDeletedFolders] : @"Are you sure you want to delete this csv file?";
    NSString *destructiveButtonTitle=numOfDeletedFolders > 1 ? @"Delete Files" : @"Delete File";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}

- (IBAction)importPressed:(UIBarButtonItem *)sender {
}

#pragma mark - Pull To Refresh

CGFloat const kRefreshViewHeight = 65;

- (NSString *)currentTimeStamp {
    NSString *timeStamp=@"Last updated: ";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    NSDate *currentDate=[NSDate new];
    dateFormatter.dateFormat=@"MM/dd/yy HH:mm";
    timeStamp=[timeStamp stringByAppendingFormat:@" %@",[dateFormatter stringFromDate:currentDate]];
    
    return timeStamp;
}

- (void)setupPullToRefreshTopView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight, SizeInPopover.width, kRefreshViewHeight)];
	[self.headerView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[self.tableView addSubview:self.headerView];
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -1/500.0;
	[self.headerView.layer setSublayerTransform:transform];
	
	self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight / 4, self.headerView.bounds.size.width, kRefreshViewHeight / 2)];
	[self.topView setBackgroundColor:[UIColor colorWithRed:0.886 green:0.906 blue:0.929 alpha:1]];
	[self.topView.layer setAnchorPoint:CGPointMake(0.5, 0.0)];
	[self.headerView addSubview:self.topView];
	
	self.topLabel = [[UILabel alloc] initWithFrame:self.topView.bounds];
	[self.topLabel setBackgroundColor:[UIColor clearColor]];
	[self.topLabel setTextAlignment:UITextAlignmentCenter];
	[self.topLabel setText:@"Pull down to refresh"];
	[self.topLabel setTextColor:[UIColor colorWithRed:0.395 green:0.427 blue:0.510 alpha:1]];
	[self.topLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
	[self.topLabel setShadowOffset:CGSizeMake(0, 1)];
	[self.topView addSubview:self.topLabel];
	
	self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kRefreshViewHeight * 3 / 4, self.headerView.bounds.size.width, kRefreshViewHeight / 2)];
	[self.bottomView setBackgroundColor:[UIColor colorWithRed:0.836 green:0.856 blue:0.879 alpha:1]];
	[self.bottomView.layer setAnchorPoint:CGPointMake(0.5, 1.0)];
	[self.headerView addSubview:self.bottomView];
	
	self.bottomLabel = [[UILabel alloc] initWithFrame:self.bottomView.bounds];
	[self.bottomLabel setBackgroundColor:[UIColor clearColor]];
	[self.bottomLabel setText:[self currentTimeStamp]];
	[self.bottomLabel setTextAlignment:UITextAlignmentCenter];
	[self.bottomLabel setTextColor:[UIColor colorWithRed:0.395 green:0.427 blue:0.510 alpha:1]];
	[self.bottomLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
	[self.bottomLabel setShadowOffset:CGSizeMake(0, 1)];
	[self.bottomView addSubview:self.bottomLabel];
	
	// Just so it's not white above the refresh view.
	UIView * aboveView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - kRefreshViewHeight)];
	[aboveView setBackgroundColor:[UIColor colorWithRed:0.886 green:0.906 blue:0.929 alpha:1]];
	[aboveView setTag:123];
	[self.tableView addSubview:aboveView];
	
	self.refreshing = NO;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[UIView animateWithDuration:duration animations:^{
		[self.headerView setFrame:CGRectMake(0, -kRefreshViewHeight, self.view.bounds.size.width, kRefreshViewHeight)];
		[self.topView setFrame:CGRectMake(0, -kRefreshViewHeight / 4, self.headerView.bounds.size.width, kRefreshViewHeight / 2)];
		[self.bottomView setFrame:CGRectMake(0, (kRefreshViewHeight / 2), self.headerView.bounds.size.width, kRefreshViewHeight / 2)];
		[self.topLabel setFrame:self.topView.bounds];
		[self.bottomLabel setFrame:self.bottomView.bounds];
		[[self.view viewWithTag:123] setFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - kRefreshViewHeight)];
	}];
}

- (void)refreshData {
	
	self.refreshing = YES;
	
	[self.topLabel setText:@"Refreshing..."];
	[UIView animateWithDuration:0.2 animations:^{[self.tableView setContentInset:UIEdgeInsetsMake(kRefreshViewHeight, 0, 0, 0)];}];
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		self.refreshing = NO;
		[UIView animateWithDuration:0.2 animations:^{[self.tableView setContentInset:UIEdgeInsetsZero];}];
        
        //Reload the csv files
        [self synchronizeWithFileSystem];
	});
}

- (void)unfoldHeaderToFraction:(CGFloat)fraction {
	[self.bottomView.layer setTransform:CATransform3DMakeRotation((M_PI / 2) - asinf(fraction), 1, 0, 0)];
	[self.topView.layer setTransform:CATransform3DMakeRotation(asinf(fraction) + (((M_PI) * 3) / 2) , 1, 0, 0)];
	[self.topView setFrame:CGRectMake(0, kRefreshViewHeight * (1 - fraction), self.view.bounds.size.width, kRefreshViewHeight / 2)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (!self.refreshing){
		
		CGFloat fraction = scrollView.contentOffset.y / -kRefreshViewHeight;
		if (fraction < 0) fraction = 0;
		if (fraction > 1) fraction = 1;
		
		[self unfoldHeaderToFraction:fraction];
		
		if (fraction == 1)[self.topLabel setText:@"Release to refresh"];
		else [self.topLabel setText:@"Pull down to refresh"];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView.contentOffset.y < -kRefreshViewHeight) {
        [self refreshData];
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //get the csv files
    [self synchronizeWithFileSystem];
    
    //Put self into editing mode
    self.tableView.editing=YES;
    
    //Initialize the engine
    self.engine=[[IEEngine alloc] init];
    
    //Initialize the conflict handler
    self.conflictHandler=[[ConflictHandler alloc] init];
    self.conflictHandler.database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
    
    //Set up for pull-to-request feature
    [self setupPullToRefreshTopView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    self.sectionFooter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, SECTION_FOOTER_HEIGHT)];
    UILabel *sectionFooter=self.sectionFooter;
    sectionFooter.font = [UIFont systemFontOfSize:17];
    sectionFooter.shadowColor = [UIColor whiteColor];
    sectionFooter.shadowOffset = CGSizeMake(0, 1);
    sectionFooter.textAlignment = UITextAlignmentCenter;
    sectionFooter.textColor = [UIColor blackColor];
    sectionFooter.backgroundColor = [UIColor clearColor];
    sectionFooter.opaque = NO;
    
    //Set the text
    int numOfFiles=[self.selectedCSVFiles count];
    NSString *fileCounter=numOfFiles>1 ? @"files" : @"file";
    self.sectionFooter.text=numOfFiles ? [NSString stringWithFormat:@"%d %@ selected.",numOfFiles,fileCounter] : @"No file selected.";
    
    return sectionFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return SECTION_FOOTER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.csvFileNames count];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Add the selected file name to the array of selected csv files
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSMutableArray *selectedFileNames=[self.selectedCSVFiles mutableCopy];
    if (![selectedFileNames containsObject:fileName])
        [selectedFileNames addObject:fileName];
    self.selectedCSVFiles=[selectedFileNames copy];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Remove the deselected file name from the array of selected csv files
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSMutableArray *selectedFileNames=[self.selectedCSVFiles mutableCopy];
    [selectedFileNames removeObject:fileName];
    self.selectedCSVFiles=[selectedFileNames copy];
}

@end
