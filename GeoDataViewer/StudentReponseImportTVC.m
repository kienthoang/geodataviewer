//
//  StudentReponseImportTVC.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "StudentReponseImportTVC.h"
#import "CSVTableViewController.h"

@interface StudentReponseImportTVC() <CSVTableViewControllerDelegate>

@end

@implementation StudentReponseImportTVC

#pragma mark - Getters and Setters

- (NSString *)csvFileExtension {
    return @".response.csv";
}

#pragma mark - UITableViewDataSource protocol methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Student Response CSV Files";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Student Response Import Cell";
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
    
    __weak StudentReponseImportTVC *weakSelf=self;
    
    //Start importing
    [self startImportingWithHandler:^(NSArray *selectedCSVFiles){
        if ([weakSelf.delegate respondsToSelector:@selector(userDidSelectFormationCSVFiles:forImportingInImportTVC:)])
            [weakSelf.delegate userDidSelectFeedbackCSVFiles:selectedCSVFiles forImportingInImportTVC:weakSelf];
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
    //Rename the files to have .response.csv extension
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *documentDirURL=[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSMutableArray *csvFileNames=self.csvFileNames.mutableCopy;
    for (NSString *fileName in fileNames) {
        NSMutableArray *nameComponents=[fileName componentsSeparatedByString:@"."].mutableCopy;
        [nameComponents removeLastObject];
        NSString *localizedName=[nameComponents componentsJoinedByString:@"."];
        NSString *newName=[localizedName stringByAppendingString:@".response.csv"];
        
        [fileManager moveItemAtURL:[documentDirURL URLByAppendingPathComponent:fileName] toURL:[documentDirURL URLByAppendingPathComponent:newName] error:NULL];
        [csvFileNames addObject:newName];
    }
    
    //Set the csv file names
    self.csvFileNames=csvFileNames.copy;
    
    //Pop navigation stack to self
    [self.navigationController popToViewController:self animated:YES];
}

@end
