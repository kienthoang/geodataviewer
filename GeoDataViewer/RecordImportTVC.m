//
//  RecordImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordImportTVC.h"
#import "CSVTableViewController.h"

@interface RecordImportTVC() <CSVTableViewControllerDelegate>

@end

@implementation RecordImportTVC

@synthesize csvFileExtension=_csvFileExtension;

#pragma mark - Getters and Setters

- (NSString *)csvFileExtension {
    return @".record.csv";
}

#pragma mark - UITableViewDataSource protocol methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Record CSV Files";
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

#pragma mark - Target Action Handlers

- (IBAction)importPressed:(UIBarButtonItem *)sender {
    [super importPressed:sender];
     
    __weak RecordImportTVC *weakSelf=self;
    
    //Start importing
    [self startImportingWithHandler:^(NSArray *selectedCSVFiles){
        if ([weakSelf.delegate respondsToSelector:@selector(userDidSelectRecordCSVFiles:forImportingInImportTVC:)])
            [weakSelf.delegate userDidSelectRecordCSVFiles:selectedCSVFiles forImportingInImportTVC:weakSelf];
    }];
}

#pragma mark - Prepare for Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Add File"]) {
        [segue.destinationViewController setAddDelegate:self];
        [segue.destinationViewController setBlacklistedExtensions:[NSArray arrayWithObjects:@".record.csv",@".formation.csv",@".response.csv",nil]];
    }
}

#pragma mark - CSVTableViewControllerDelegate protocol methods

- (void)csvTableViewController:(CSVTableViewController *)sender userDidChooseFilesWithNames:(NSArray *)fileNames {
    //Rename the files to have .record.csv extension
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSMutableArray *csvFileNames=self.csvFileNames.mutableCopy;
    for (NSString *fileName in fileNames) {
        NSMutableArray *nameComponents=[fileName componentsSeparatedByString:@"."].mutableCopy;
        [nameComponents removeLastObject];
        NSString *localizedName=[nameComponents componentsJoinedByString:@"."];
        NSString *newName=[localizedName stringByAppendingString:@".record.csv"];
        
        [fileManager moveItemAtURL:[documentDirURL URLByAppendingPathComponent:fileName] toURL:[documentDirURL URLByAppendingPathComponent:newName] error:NULL];
        [csvFileNames addObject:newName];
    }
    
    //Set the csv file names
    self.csvFileNames=csvFileNames.copy;
    
    //Pop navigation stack to self
    [self.navigationController popToViewController:self animated:YES];
}

@end
