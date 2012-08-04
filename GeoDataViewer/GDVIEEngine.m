//
//  GDVIEEngine.m
//  GeoDataViewer
//
//  Created by Kien Hoang on 8/1/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GDVIEEngine.h"

#import "ValidationMessageBoard.h"

#import "TextInputFilter.h"
#import "IEFormatter.h"
#import "ColorManager.h"

#import "Bedding+Creation.h"
#import "Contact+Creation.m"
#import "Fault+Creation.h"
#import "JointSet+Creation.h"
#import "Other+Creation.h"

@interface GDVIEEngine()

@property (nonatomic, strong) NSArray *selectedFilePaths;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSMutableArray *formations;
@property (nonatomic, strong) NSMutableDictionary *groupDictionaryByID;
@property (nonatomic, strong) NSArray *formationFolders;

@property (nonatomic, strong) ValidationMessageBoard *validationMessageBoard;

@end

@implementation GDVIEEngine

@synthesize database=_database;

@synthesize selectedFilePaths=_selectedFilePaths;
@synthesize records=_records;
@synthesize formations=_formations;
@synthesize formationFolders=_formationFolders;

@synthesize validationMessageBoard=_validationMessageBoard;

@synthesize groupDictionaryByID=_groupDictionaryByID;

@synthesize delegate=_delegate;

typedef void (^database_save_t)(UIManagedDocument *database);

- (void)saveDatabaseWithCompletionHandler:(database_save_t)completionHandler {
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success)
            completionHandler(self.database);
        else
            NSLog(@"Failed to save changes to database!");
    }];
}

//enum for columnHeadings
typedef enum columnHeadings{Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

#pragma mark - Getters
-(NSMutableDictionary *) groupDictionaryByID {
    if(!_groupDictionaryByID) {
        _groupDictionaryByID = [NSMutableDictionary dictionary];
    }
    return _groupDictionaryByID;
}

-(NSMutableArray *) projects {
    if(!_records) 
        _records = [[NSMutableArray alloc] init];
    
    return _records;
}

-(NSMutableArray *) formations {
    if(!_formations) 
        _formations = [[NSMutableArray alloc] init];
    
    return _formations;
}

- (NSArray *)formationFolders {
    if (!_formationFolders)
        _formationFolders=[NSArray array];
    
    return _formationFolders;
}

- (ValidationMessageBoard *)validationMessageBoard {
    if (!_validationMessageBoard)
        _validationMessageBoard=[[ValidationMessageBoard alloc] init];
    
    return _validationMessageBoard;
}

- (NSMutableArray *)records {
    if (!_records)
        _records=[NSMutableArray array];
    return _records;
}

#pragma mark - Data Managers

- (NSDate *)dateFromDateToken:(NSString *)dateToken andTimeToken:(NSString *)timeToken {
    //Get date and time components and create a NSDate from them
    NSArray *dateComponents = [dateToken componentsSeparatedByString:@"/"];
    NSArray *timeComponents = [timeToken componentsSeparatedByString:@":"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    //Set the date components
    comps.year=[[NSString stringWithFormat:@"20%@",[dateComponents objectAtIndex:2]] intValue];
    comps.month=[[dateComponents objectAtIndex:0] intValue];
    comps.day=[[dateComponents objectAtIndex:1] intValue];
    
    //Set the time components
    comps.hour=[[timeComponents objectAtIndex:0] intValue];
    comps.minute=[[timeComponents objectAtIndex:1] intValue];
    comps.second=[[timeComponents objectAtIndex:2] intValue];
    
    //Create a NSDate obj from the date and time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:comps];
}

- (NSData *)imageInDocumentDirectoryForName:(NSString *)imageFileName {
    NSData *imageData=nil;
    
    //to set the image, first get the image from the images directory
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [urlArray.lastObject path];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:imageFileName];
    
    //Get the image data if the file exists
    if([fileManager fileExistsAtPath:imageFilePath])
        imageData=[NSData dataWithContentsOfFile:imageFilePath];
    
    return imageData;
}

#pragma mark - Record Importing

- (Record *)recordForTokenArray:(NSArray *)tokenArray {
    //Create the record dictionary info from the token array
    Record *record=nil;
    NSMutableDictionary *recordInfo=[NSMutableDictionary dictionary];
    
    //Populate the common fields for all the records
    [recordInfo setObject:[tokenArray objectAtIndex:Name] forKey:RECORD_NAME];
    [recordInfo setObject:[tokenArray objectAtIndex:Strike] forKey:RECORD_STRIKE];
    [recordInfo setObject:[tokenArray objectAtIndex:Dip] forKey:RECORD_DIP];   
    [recordInfo setObject:[tokenArray objectAtIndex:dipDirection] forKey:RECORD_DIP_DIRECTION];
    [recordInfo setObject:[tokenArray objectAtIndex:Observations] forKey:RECORD_FIELD_OBSERVATION];
    [recordInfo setObject:[tokenArray objectAtIndex:Latitude] forKey:RECORD_LATITUDE];
    [recordInfo setObject:[tokenArray objectAtIndex:Longitude] forKey:RECORD_LONGITUDE];
    [recordInfo setObject:[tokenArray objectAtIndex:FormationField] forKey:RECORD_FORMATION];
    [recordInfo setObject:[tokenArray objectAtIndex:LowerFormation] forKey:RECORD_LOWER_FORMATION];
    [recordInfo setObject:[tokenArray objectAtIndex:UpperFormation] forKey:RECORD_UPPER_FORMATION];
    [recordInfo setObject:[tokenArray objectAtIndex:Trend] forKey:RECORD_TREND];
    [recordInfo setObject:[tokenArray objectAtIndex:Plunge] forKey:RECORD_PLUNGE];
            
    //Populate the date field
    NSString *dateToken = [[tokenArray objectAtIndex:Date] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *timeToken = [[tokenArray objectAtIndex:Time] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [recordInfo setObject:[self dateFromDateToken:dateToken andTimeToken:timeToken] forKey:RECORD_DATE]; 
            
    //Create the record
    NSString *typeToken=[tokenArray objectAtIndex:Type];
    if([typeToken isEqualToString:@"Contact"]) {
        record=[Contact recordForInfo:recordInfo.copy inManagedObjectContext:self.database.managedObjectContext];
    } else if ([typeToken isEqualToString:@"Bedding"]) {
        record=[Bedding recordForInfo:recordInfo.copy inManagedObjectContext:self.database.managedObjectContext];
    } else if([typeToken isEqualToString:@"Joint Set"]) {
        record=[JointSet recordForInfo:recordInfo.copy inManagedObjectContext:self.database.managedObjectContext];
    } else if([typeToken isEqualToString:@"Fault"]) {        
        record=[Fault recordForInfo:recordInfo.copy inManagedObjectContext:self.database.managedObjectContext];
    } else if([typeToken isEqualToString:@"Other"]) {
        record=[Other recordForInfo:recordInfo.copy inManagedObjectContext:self.database.managedObjectContext];
    }
       
    return record;
}

- (void)constructRecordsFromCSVFileWithPath:(NSString *)path {    
    //Get all the token arrays, each of them corresponding to a line in the csv file)
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy;
    
    if([[[tokenArrays objectAtIndex:0] objectAtIndex:0] isEqualToString:METADATA_HEADER]) {
        //Get the group from the metadata info
        NSString *groupName=[[tokenArrays objectAtIndex:1] objectAtIndex:1];
        NSString *groupID=[[tokenArrays objectAtIndex:2] objectAtIndex:1];
        NSNumber *faulty=[NSNumber numberWithBool:NO];
       
        //Try to get the student group from the student-group-by-id dictionary
        Group *studentGroup=[self.groupDictionaryByID objectForKey:groupID];
                
        //If it does not exist, create a new one and erase all of its folders
        if (!studentGroup) {
             NSDictionary *groupInfo=[NSDictionary dictionaryWithObjectsAndKeys:groupName,GDVStudentGroupName,groupID,GDVStudentGroupIdentifier,faulty,GDVStudentGroupIsFaulty, nil];
            studentGroup=[Group studentGroupForInfo:groupInfo inManagedObjectContext:self.database.managedObjectContext];
            [self.groupDictionaryByID setObject:studentGroup forKey:groupID];
            [studentGroup removeFolders:studentGroup.folders];
        }
                
        //Create the folder from the file path
        NSString *folderName=[[tokenArrays objectAtIndex:3] objectAtIndex:1];
        Folder *folder=[Folder folderForName:folderName inManagedObjectContext:self.database.managedObjectContext];
        folder.group=studentGroup;
        
        //Remove the metadata token arrays and the record header token array
        NSIndexSet *indexes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)];
        [tokenArrays removeObjectsAtIndexes:indexes];
        
        //Now create transient records from the rest
        for(NSArray *tokenArray in tokenArrays.copy) {
            //If the current token array does not have enough tokens, add an error message to the message board
            if(tokenArray.count!=NUMBER_OF_COLUMNS_PER_RECORD_LINE) {
                NSString *error=[NSString stringWithFormat:@"Invalid CSV File Format: %@. Please ensure that your csv file has the required format.",path.lastPathComponent];
                [self.validationMessageBoard addErrorWithMessage:error];
                NSLog(@"Corrupted: %@",tokenArray);
            }
            
            //Else, process the token array and contruct a corresponding record
            else {
                //Create a record from the token array
                Record *record=[self recordForTokenArray:tokenArray];
                record.folder=folder;                
            }
        }
    } else {
        //No metadata, add an error message
        NSString *error=[NSString stringWithFormat:@"Missing metadata in: %@. Please ensure that your csv file has the required format.",path.lastPathComponent];
        [self.validationMessageBoard addErrorWithMessage:error];
        NSLog(@"Missing metadata: %@",path.lastPathComponent);
    }
}

/*
 Column Headings:
 "Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"
 */
-(void)createRecordsFromCSVFiles:(NSArray *)files
{       
    //get paths to the selected files
    self.selectedFilePaths = [self getSelectedFilePaths:files];
        
    [self.database.managedObjectContext performBlock:^{
        //Iterate through each csv files and create records from each of them
        for (NSString *path in self.selectedFilePaths) {
            //Construct the records
            [self constructRecordsFromCSVFileWithPath:path];
        }
        
        //Save to database
        [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){
            //Notify the delegate that the importing was finished
            [self.delegate engineDidFinishProcessingRecords:self];
        }];
    }];
}

#pragma mark - CSV File Parsing

-(NSArray *)tokenArraysFromFile:(NSString *)filePath
{
    //if file does not exist, add the error message to the validation message board
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        NSString *errorMessage=[NSString stringWithFormat:@"CSV File with name %@ cannot be found!",filePath.lastPathComponent];
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
        return nil;
    }
    
    //Array of token arrays read from the file
    NSMutableArray *tokenArrays = [NSMutableArray array];
    
    //read the contents of the file
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    //get all lines in the file
    NSArray *allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //fix the case where newline characters (record separators) appear in the data field themselves
    allLines = [self fixNewLineCharactersInData:allLines];
    
    //Skip blank lines and parse the rest
    for(NSString *line in allLines) {
        if (line.length)
            [tokenArrays addObject:[self tokenArrayForLine:line]];
    }
    
    return tokenArrays.copy;
}

-(NSArray *)getSelectedFilePaths:(NSArray *)fileNames;
{   
    //Get the document directory path
    NSMutableArray *paths = [NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentDirPath = [urlArray.lastObject path];
    
    //Get the csv file paths from the document directory
    for (NSString *fileName in fileNames)
        [paths addObject:[documentDirPath stringByAppendingPathComponent:fileName]];
    
    return paths.copy;
}

- (NSArray *)tokenArrayForLine:(NSString *)line
{
    //Get tokens from each line
    NSMutableArray *tokenArray = [line componentsSeparatedByString:@","].mutableCopy;
    tokenArray = [self separateRecordsOrFieldsByCountingQuotations:tokenArray byAppending:@","];
    
    //Filter each token (get rid of extra quotation marks or any auxiliary, csv-added symbols)
    NSArray *filteredTokenArray=[self filterTokenArray:tokenArray.copy];
    
    return filteredTokenArray;
}
-(NSMutableArray *) fixNewLineCharactersInData:(NSArray *)records {
    return [self separateRecordsOrFieldsByCountingQuotations:records byAppending:@"\n"];
}

-(NSMutableArray *) separateRecordsOrFieldsByCountingQuotations:(NSArray *) array byAppending:(NSString *) separator {
    NSString *merged=@"";
    NSString *current=@"";
    BOOL repeat=NO;
    NSMutableArray *copy = [array mutableCopy];
    do {
        repeat = NO;
        int length = copy.count;
        for(int i = 0; i<length; i++) {
            current = [copy objectAtIndex:i];
            int quotes = [[current componentsSeparatedByString:@"\""] count]-1; //number of quotes
            if(quotes%2) { // if odd, merge with the next string value
                merged = [current stringByAppendingFormat:@"%@%@",separator,[copy objectAtIndex:i+1]];
                [copy replaceObjectAtIndex:i withObject:merged];
                [copy removeObjectAtIndex:i+1];
                repeat = YES;
                length = copy.count;
                break;
            }
        }
    } while (repeat);
    
    return copy;
}

- (NSArray *)filterTokenArray:(NSArray *)tokenArray {
    NSMutableArray *mutableTokenArray=tokenArray.mutableCopy;
    for (int i=0;i<tokenArray.count;i++) {
        NSString *token=[tokenArray objectAtIndex:i];
        [mutableTokenArray replaceObjectAtIndex:i withObject:[TextInputFilter stringFromCSVCompliantString:token]];
    }        
    
    return mutableTokenArray.copy;
}

@end
