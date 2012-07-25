//
//  PrototypeRecordTableViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeRecordTableViewController.h"

#import "Record+DateAndTimeFormatter.h"
#import "Image.h"

@interface PrototypeRecordTableViewController ()

#pragma mark - Image Cache
@property (nonatomic,strong) NSMutableDictionary *imageCache;

@end

@implementation PrototypeRecordTableViewController

@synthesize database=_database;
@synthesize folder=_folder;
@synthesize imageCache=_imageCache;

#pragma mark - Controller State Initialization

- (void)setupFetchedResultsController {
    //Set up the fetched results controller to fetch records
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:@"Record"];
    request.predicate=[NSPredicate predicateWithFormat:@"folder.folderName=%@",self.folder.folderName];
    request.sortDescriptors=[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - Setters

- (void)normalizeDatabase {
    //If the managed document is closed, open it
    if (self.database.documentState==UIDocumentStateClosed) {
        [self.database openWithCompletionHandler:^(BOOL success){
            //Set up the fetched result controller
            [self setupFetchedResultsController];
        }];
    }
    
    //Else if the managed document is open, just use it
    else if (self.database.documentState==UIDocumentStateNormal) {
        //Set up the fetched result controller
        [self setupFetchedResultsController];
    }
}

- (void)setDatabase:(UIManagedDocument *)database {
    if (_database!=database) {
        _database=database;
        
        //Set up fetchedResultsController
        if (self.folder) {
            //Make sure the document is open and set up the fetched result controller
            [self normalizeDatabase]; 
        }
    }
}

- (void)setFolder:(Folder *)folder {
    _folder=folder;
    
    //Set up fetchedResultsController
    if (self.folder)
        [self setupFetchedResultsController];
}

#pragma mark - Getters

- (NSMutableDictionary *)imageCache {
    if (!_imageCache)
        _imageCache=[NSMutableDictionary dictionary];
    
    return _imageCache;
}

#pragma mark - Alert Generators

//Put up an alert about some database failure with specified message
- (void)putUpDatabaseErrorAlertWithMessage:(NSString *)message {
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Database Error" 
                                                  message:message 
                                                 delegate:nil 
                                        cancelButtonTitle:@"Dismiss" 
                                        otherButtonTitles: nil];
    [alert show];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.database) {
        //Set up the database using the GeoDatabaseManager fetch method=====>the block will get called only the first time the database gets created
        //success is YES if the database saving process succeeded or NO otherwise
        self.database=[[GeoDatabaseManager standardDatabaseManager] fetchDatabaseFromDisk:self completion:^(BOOL success){
            //May be show up an alert if not success?
            if (!success) {
                //Put up an alert
                [self putUpDatabaseErrorAlertWithMessage:@"Failed to access the database. Please make sure the database is not corrupted."];
            } 
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Flush the image cache
    [self flushImageCache];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Records";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Record Cell";
    
    CustomRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CustomRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];  
    
    //show the name, date and time
    cell.name.text=[NSString stringWithFormat:@"%@",record.name];
    cell.type.text=[record.class description];
    cell.date.text=[Record dateFromNSDate:record.date];
    cell.time.text = [Record timeFromNSDate:record.date];
    
    //Hide the spinner (in case it's still animating as the cell has been reused)
    cell.spinner.hidden=YES;
    
    //Set the image to nil (for asyncronous image loading)
    cell.recordImageView.image=nil;
    
    //Load the image asynchronously
    [self loadImageForCell:cell withRecord:record];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)cacheImage:(UIImage *)image forHashValue:(id)hashValue {
    //If the cache has more than 30 images, flush it
    if (self.imageCache.count>ImageCacheCapacity)
        [self flushImageCache];
    
    //Cache the given image
    [self.imageCache setObject:image forKey:hashValue];
}

- (UIImage *)imageInCacheWithHashValue:(id)hashValue {
    return [self.imageCache objectForKey:hashValue];
}

- (void)flushImageCache {
    self.imageCache=[NSMutableDictionary dictionary];
}

- (void)loadImageForCell:(CustomRecordCell *)cell withRecord:(Record *)record {
    if (record.image) {
        NSNumber *hashValue=[NSNumber numberWithInt:[self.fetchedResultsController indexPathForObject:record].row];
        UIImage *image=[self imageInCacheWithHashValue:hashValue];
        if (image)
            cell.recordImageView.image=image;
        
        //Load and cache the image if it's not there
        else {
            //Show the spinner
            cell.spinner.hidden=NO;
            [cell.spinner startAnimating];
            
            //Load the image from database asynchronously
            dispatch_queue_t image_loader=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(image_loader, ^{
                UIImage *image = [[UIImage alloc] initWithData:record.image.imageData];
                [self cacheImage:image forHashValue:hashValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Load the image
                    if (!cell.recordImageView.image) {
                        cell.recordImageView.image=image;
                        
                        //Stop the spinner
                        [cell.spinner stopAnimating];
                        cell.spinner.hidden=YES;
                    }
                });
            });
            
            dispatch_release(image_loader);
        }
    }
}

- (void)loadImagesForCells:(NSArray *)cells {
    for (CustomRecordCell *cell in cells) {
        NSIndexPath *indexPath=[self.tableView indexPathForCell:cell];
        Record *record=[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //Try to retrieve the image from the cache
        [self loadImageForCell:cell withRecord:record];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //Load images for visible cells
        [self loadImagesForCells:self.tableView.visibleCells];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //Load images for visible cells
    [self loadImagesForCells:self.tableView.visibleCells];
}

@end
