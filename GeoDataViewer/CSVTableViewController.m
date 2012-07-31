//
//  CSVTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/14/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "CSVTableViewController.h"

@interface CSVTableViewController() <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation CSVTableViewController
@synthesize addButton = _addButton;

@synthesize blacklistedExtensions=_blacklistedExtensions;
@synthesize delegate=_delegate;

- (void)updateButtons {
    int numFiles=self.selectedCSVFiles.count;
    
    //Update the import button
    NSString *title=numFiles > 1 ? [NSString stringWithFormat:@"Add Files (%d)",numFiles] : [NSString stringWithFormat:@"Add File (%d)",numFiles];
    self.addButton.title=numFiles ? title : @"Add File";
    self.addButton.enabled=numFiles>0;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get the list of csv files from the document directories
    NSMutableArray *csvFileNames=[NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *urls=[fileManager contentsOfDirectoryAtPath:[documentDirURL path] error:NULL];
    for (NSURL *url in urls) {
        //If the file name has extension .csv and not one of the blacklisted extensions, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:@".csv"]) {
            BOOL blacklisted=NO;
            for (NSString *suffix in self.blacklistedExtensions) {
                if ([fileName hasSuffix:suffix])
                    blacklisted=YES;
            }
            
            if (!blacklisted)
                [csvFileNames addObject:fileName];
        }
    }
    self.csvFileNames=csvFileNames;
}

#pragma mark - UITableViewDataSource protocol methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"CSV Files";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CSV File Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSString *fileNameWithoutExtension=[[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    cell.textLabel.text=fileNameWithoutExtension;
    
    return cell;
}

#pragma mark - Target Action Handlers

- (IBAction)selectAll:(UIBarButtonItem *)sender {
    //Select all the csv files
    self.selectedCSVFiles=self.csvFileNames;
    
    //Select all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (IBAction)selectNone:(UIBarButtonItem *)sender {
    //Empty the selected csv files
    self.selectedCSVFiles=[NSArray array];
    
    //Deselect all the rows
    for (UITableViewCell *cell in self.tableView.visibleCells)
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:YES];
}

- (IBAction)addPressed:(UIBarButtonItem *)sender {
    //Put up an actionsheet
    int numOfAddedCSVFiles=self.selectedCSVFiles.count;
    NSString *message=numOfAddedCSVFiles > 1 ? [NSString stringWithFormat:@"Are you sure you want to add %d csv files? They will be renamed to contain appropriate extensions.",numOfAddedCSVFiles] : @"Are you sure you want to add this csv file? It will be renamed to contain appropriate extension.";
    NSString *destructiveButtonTitle=numOfAddedCSVFiles > 1 ? @"Add Files" : @"Add File";
    
    //Put up an alert
    UIActionSheet *deleteActionSheet=[[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate protocol methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the action sheet is the add file action sheet and user clicks "Add Files" or "Add File", add the file(s)
    NSSet *deleteButtonTitles=[NSSet setWithObjects:@"Add Files",@"Add File", nil];
    NSString *clickedButtonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
    if (self.tableView.editing && [deleteButtonTitles containsObject:clickedButtonTitle]) {
        //Notify the delegate
        [self.delegate csvTableViewController:self userDidChooseFilesWithNames:self.selectedCSVFiles];
    }
}

@end
