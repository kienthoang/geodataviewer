//
//  RecordImportTVC.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/11/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordImportTVC.h"

@interface RecordImportTVC()

@end

@implementation RecordImportTVC

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
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

#pragma mark - ConflictHandlerDelegate methods

#pragma mark - ConflictHandlerDelegate protocol methods

- (void)conflictHandler:(ConflictHandler *)sender conflictDidHappenWithRecords:(NSArray *)records {
    //Put up alert
    NSString *message=@"";
    for (NSString *record in records) {
        message=[message stringByAppendingString:[NSString stringWithFormat:@"Folder
                                                  }
                                                  }
                                                  
- (void)conflictHandler:(ConflictHandler *)sender conflictDidHappenWithFormations:(NSArray *)formations {
                                                      
}

@end
