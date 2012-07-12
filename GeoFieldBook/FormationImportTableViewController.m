//
//  FormationImportTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationImportTableViewController.h"

@interface FormationImportTableViewController ()

@property (nonatomic,strong) UILabel *sectionFooter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *importButton;

@end

@implementation FormationImportTableViewController

@synthesize csvFileNames=_csvFileNames;
@synthesize selectedCSVFiles=_selectedCSVFiles;

@synthesize sectionFooter=_sectionFooter;
@synthesize importButton = _importButton;

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
}

#pragma mark - Target-Action Handlers

- (IBAction)importPressed:(UIBarButtonItem *)sender {
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Get the list of csv files from the document directories
    NSMutableArray *csvFileNames=[NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *urls=[fileManager contentsOfDirectoryAtPath:[documentDirURL path] error:NULL];
    for (NSURL *url in urls) {
        //If the file name has extension .record.csv, add it to the array of csv files
        NSString *fileName=[url lastPathComponent];
        if ([fileName hasSuffix:@".record.csv"]) {
            [csvFileNames addObject:fileName];
        }
    }
    self.csvFileNames=csvFileNames;
    
    //Put self into editing mode
    self.tableView.editing=YES;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Record CSV Files";
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Record Import Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSString *fileNameWithoutExtension=[[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    cell.textLabel.text=fileNameWithoutExtension;
    
    return cell;
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
    
    //Enable/Disable the import button
    self.importButton.enabled=self.selectedCSVFiles.count>0;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Remove the deselected file name from the array of selected csv files
    NSString *fileName=[self.csvFileNames objectAtIndex:indexPath.row];
    NSMutableArray *selectedFileNames=[self.selectedCSVFiles mutableCopy];
    [selectedFileNames removeObject:fileName];
    self.selectedCSVFiles=[selectedFileNames copy];
    
    //Enable/Disable the import button
    self.importButton.enabled=self.selectedCSVFiles.count>0;
}
@end
