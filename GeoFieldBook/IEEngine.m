//
//  IEEngine.m
//  GeoFieldBook
//
//  Created by excel 2012 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "IEEngine.h"
#import "TransientRecord.h"
#import "TransientFault.h"
#import "TransientBedding.h"
#import "TransientContact.h"
#import "TransientJointSet.h"
#import "TransientOther.h"
#import "TransientFormation.h"
#import "TransientImage.h"
#import "TransientFormation_Folder.h"
#import "TransientProject.h"

#import "ValidationMessageBoard.h"

@interface IEEngine()

@property (nonatomic, strong) NSArray *selectedFilePaths;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSMutableArray *formations;
@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) NSArray *formationFolders;

@property (nonatomic, strong) ValidationMessageBoard *validationMessageBoard;

@end

@implementation IEEngine

@synthesize handler=_handler;
@synthesize selectedFilePaths=_selectedFilePaths;
@synthesize records=_records;
@synthesize formations=_formations;
@synthesize folders=_folders;
@synthesize formationFolders=_formationFolders;

@synthesize validationMessageBoard=_validationMessageBoard;

//enum for columnHeadings
typedef enum columnHeadings{Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

#pragma mark - Getters
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

#pragma mark - Reading of Record Files

- (TransientRecord *)recordForCSVLineTokenArray:(NSArray *)lineArray withFolderName:(NSString *)folderName {
    TransientRecord *record=nil;
    //identify the record type and populate record specific fields
    if([[lineArray objectAtIndex:1] isEqualToString:@"Contact"]) {
        record =[[TransientContact alloc] init];
        
        //Set lower formation
        TransientFormation *lowerFormation=[[TransientFormation alloc] init];
        lowerFormation.formationName=[lineArray objectAtIndex:LowerFormation];
        [(TransientContact *)record setLowerFormation:lowerFormation];
        
        //Set upper formation
        TransientFormation *upperFormation=[[TransientFormation alloc] init];
        upperFormation.formationName=[lineArray objectAtIndex:UpperFormation];
        [(TransientContact *)record setUpperFormation:upperFormation];
    } else if ([[lineArray objectAtIndex:1] isEqualToString:@"Bedding"]) {
        record = [[TransientBedding alloc] init];
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[lineArray objectAtIndex:FormationField];
        [(TransientBedding *)record setFormation:formation];
    } else if([[lineArray objectAtIndex:1] isEqualToString:@"Joint Set"]) {
        record = [[TransientJointSet alloc] init]; 
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[lineArray objectAtIndex:FormationField];
        [(TransientJointSet *)record setFormation:formation];
    } else if([[lineArray objectAtIndex:1] isEqualToString:@"Fault"]) {
        record = [[TransientFault alloc] init];
        
        //Set the plunge and trend
        [(TransientFault *)record setPlunge:[lineArray objectAtIndex:Plunge]];
        [(TransientFault *)record setTrend:[lineArray objectAtIndex:Trend]];
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[lineArray objectAtIndex:FormationField];
        [(TransientFault *)record setFormation:formation];
    } else if([[lineArray objectAtIndex:1] isEqualToString:@"Other"]) {
        record = [[TransientOther alloc] init];            
    }
    
    //now populate the common fields for all the records and save the errors messages if there's any
    NSString *errorMessage=nil;
    record.name = [lineArray objectAtIndex:Name];
    
    //Set the strike value with validations
    if ((errorMessage=[record setStrikeWithValidations:[lineArray objectAtIndex:Strike]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the dip value with validations
    if ((errorMessage=[record setDipWithValidations:[lineArray objectAtIndex:Dip]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];

    //Set the dip direction value with validations
    if ((errorMessage=[record setDipDirectionWithValidations:[lineArray objectAtIndex:dipDirection]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the field observation value with validations
    if ((errorMessage=[record setFieldObservationWithValidations:[lineArray objectAtIndex:Observations]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the latitude value with validations
    if ((errorMessage=[record setLatitudeWithValidations:[lineArray objectAtIndex:Latitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the longitude value with validations
    if ((errorMessage=[record setLongitudeWithValidations:[lineArray objectAtIndex:Longitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    
    //separate by spaces to create a NSDate object from the string
    NSString *dateColumn = [[lineArray objectAtIndex:Date] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *timeColumn = [[lineArray objectAtIndex:Time] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *dateArray = [dateColumn componentsSeparatedByString:@"/"];
    NSArray *timeArray = [timeColumn componentsSeparatedByString:@":"];
 
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"January",@"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
    NSArray *values = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:6],[NSNumber numberWithInt:7],[NSNumber numberWithInt:8],[NSNumber numberWithInt:9],[NSNumber numberWithInt:10],[NSNumber numberWithInt:11],[NSNumber numberWithInt:12], nil];
     
    
    NSDictionary *months = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setYear:[[NSString stringWithFormat:@"20%@",[dateArray objectAtIndex:2]] intValue]];
    [comps setMonth:(NSInteger)[months valueForKey:[dateArray objectAtIndex:0]]];
    [comps setDay:[[dateArray objectAtIndex:1] intValue]];
    
    [comps setHour:[[timeArray objectAtIndex:0] intValue]];
    [comps setMinute:[[timeArray objectAtIndex:1] intValue]];
    [comps setSecond:[[timeArray objectAtIndex:2] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *newDate = [gregorian dateFromComponents:comps]; 
    
    //finally populate the date field
    record.date = newDate;
    
    // populate the date and time strings in the transient records
    record.dateString = [lineArray objectAtIndex:Date];
    record.timeString = [lineArray objectAtIndex:Time];
    
    //to set the image, first get the image from the images directory
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlsArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [[urlsArray objectAtIndex:0] path];
    NSString *imageFilePath = [documentsDirectory stringByAppendingFormat:@"/%@", [lineArray objectAtIndex:imageName]];
    
    //Set the image
    if([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]){
        //now set the image content
        record.image=[[TransientImage alloc] init];
        NSData *imageData=[NSData dataWithContentsOfFile:imageFilePath];
        record.image.imageData = imageData;
    }
    
    //Set the folder
    for (TransientProject *folder in self.folders) {
        if ([folder.folderName isEqualToString:folderName]) {
            record.folder=folder;
            break;
        }
    }
        
    return record;
}

- (NSArray *)constructRecordsFromCSVFileWithPath:(NSString *)path {
    NSMutableArray *records=[NSMutableArray array];;
    
    //this is an array of array
    NSMutableArray *lineRecordsInAFile = [[self getLinesFromFile:path] mutableCopy];
    
    //remove the first line which is simply the column headings
    [lineRecordsInAFile removeObjectAtIndex:0];
    
    //now create transient objects from the rest
    for(NSArray *lineArray in lineRecordsInAFile) { //for each line in file, i.e. each single record
        
        if(lineArray.count!=NUMBER_OF_COLUMNS_PER_RECORD_LINE) { //not enough/more fields in the record
            [self.validationMessageBoard addErrorWithMessage:@"Invalid CSV File Format. Please ensure that your csv file has the required format."];
        }
        
        else {
            //Create a transient record from the line array
            NSString *folderName=[[[path lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0];
            TransientRecord *record=[self recordForCSVLineTokenArray:lineArray withFolderName:folderName];
            
            //add the record to the arra of records
            [records addObject:record];
        }
    }
    
    return [records copy];
}

- (NSArray *)createFoldersFromCSVFiles:(NSArray *)files {
    NSMutableArray *transientFolders=[NSMutableArray arrayWithCapacity:files.count];
    for (NSString *csvFile in files) {
        NSString *folderName=[[csvFile componentsSeparatedByString:@"."] objectAtIndex:0];
        TransientProject *folder=[[TransientProject alloc] init];
        folder.folderName=folderName;
        [transientFolders addObject:folder];
    }
    
    return [transientFolders copy];
}

/*
 Column Headings:
 "Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"
 */
-(void)createRecordsFromCSVFiles:(NSArray *)files
{   
    //get paths to the selected files
    self.selectedFilePaths = [self getSelectedFilePaths:files];
    
    //Create the folders
    self.folders=[self createFoldersFromCSVFiles:files];
    
    //Iterate through each csv files and create transient records from each of them
    for (NSString *path in self.selectedFilePaths) {
        //Construct the records
        NSArray *records=[self constructRecordsFromCSVFileWithPath:path];
        
        //Add them to self.records
        [self.records addObjectsFromArray:records];
    }
    
    //now call the handler and pass it the array of records created ... 
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount) {
        [self.handler processTransientRecords:nil 
                                   andFolders:nil
                     withValidationMessageLog:self.validationMessageBoard.allMessages];
        
        //Reset the validation message board
        [self.validationMessageBoard clearBoard];
    }
    else {
        [self.handler processTransientRecords:self.records 
                                   andFolders:self.folders 
                     withValidationMessageLog:self.validationMessageBoard.warningMessages];

    }
}

#pragma mark - Reading of Formation files

- (void)constructFormationsFromCSVFilePath:(NSString *)path {
    //this is an array lines, which is an array of tokens
    NSMutableArray *lineRecordsInAFile = [[self getLinesFromFile:path] mutableCopy];
    
    //for each array of tokens 
    NSMutableArray *formationFolders=[self.formationFolders mutableCopy];
    for(int index=0;index<lineRecordsInAFile.count;index++) {
        //Create one formation for each line
        NSMutableArray *record=[lineRecordsInAFile objectAtIndex:index];
        NSString *folder = [record objectAtIndex:0];
        [record removeObjectAtIndex:0];
        TransientFormation_Folder *newFormationFolder = [[TransientFormation_Folder alloc] init];
        newFormationFolder.folderName = folder;
        
        //Save the newly created transient formation folder
        [formationFolders addObject:newFormationFolder];
        
        //Keep track of the sort number (formations will be sorted by the order they are in the csv file)
        int sortNumber=1;
        
        //for each token(formation) in such an array of line record(formation folder)
        for(NSString *formation in  record) {
            //if the formation name is not empty
            if (formation.length) {
                TransientFormation *newFormation = [[TransientFormation alloc] init];
                newFormation.formationFolder = newFormationFolder;
                newFormation.formationName = formation;
                newFormation.formationSortNumber=[NSNumber numberWithInt:sortNumber++];
                [self.formations addObject:newFormation];
            }
        }
    }
    
    self.formationFolders=formationFolders.copy;
}

- (void)createFormationsFromCSVFiles:(NSArray *) files
{
    //get the complete file paths for the selected files that exist
    self.selectedFilePaths=[self getSelectedFilePaths:files];
    
    //read each of those files line by line and create the formation objects and add it to self.formations array.
    for(NSString *path in self.selectedFilePaths) {
        //Construct formations from the file path
        [self constructFormationsFromCSVFilePath:path];
    }
        
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount)
        [self.handler processTransientFormations:nil 
                             andFormationFolders:nil
                        withValidationMessageLog:self.validationMessageBoard.allMessages];
    else
        [self.handler processTransientFormations:self.formations.copy 
                             andFormationFolders:self.formationFolders 
                        withValidationMessageLog:self.validationMessageBoard.warningMessages];
}

#pragma mark - CSV File Parsing

-(NSArray *) getLinesFromFile:(NSString *) filePath
{
    NSMutableArray *records = [[NSMutableArray alloc] init]; //array(of lines) of arrays(of tokens in each line)
    //if file does not exist, show error
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"data file was not found :(");
        return nil;
    }
    
    //read the contents of the file
    NSError *error;
    NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    //get all lines in the file
    NSArray *allLines = [content componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
    //fix the case where newline characters (record separators) appear in the data field themselves
    allLines = [self fixNewLineCharactersInData:allLines];
    
    for(NSString *line in allLines) //skip the first line
        [records addObject:[self parseLine:line]];
    
    return records;
    
}

-(NSArray *)getSelectedFilePaths:(NSArray *)fileNames;
{   
    //Get the document directory path
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *pathsArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [[pathsArray objectAtIndex:0] path];
    
    //Get the csv file paths from the document directory
    for (NSString *file in fileNames)
        [paths addObject:[documentsDirectory stringByAppendingFormat:@"/%@",file]];
    
    return paths;
}

- (NSArray *)parseLine:(NSString *) line
{
    //log to see if each individual line (record) is extracted properly
    //NSLog(@"Individual record: %@", line);
    
    NSMutableArray *values = [[line componentsSeparatedByString:@","] mutableCopy];
    
    values = [self separateRecordsOrFieldsByCountingQuotations:values byAppending:@","];
    
    [self fixDoubleQuotationsWhileParsingLine:values];
    
    return values;
}
-(NSMutableArray *) fixNewLineCharactersInData:(NSArray *)records {
    return [self separateRecordsOrFieldsByCountingQuotations:records byAppending:@"\n"];
}

-(NSMutableArray *) separateRecordsOrFieldsByCountingQuotations:(NSArray *) array byAppending:(NSString *) separator {
    NSString *merged=@"";
    NSString *current=@"";
    BOOL repeat;
    NSMutableArray *copy = [array mutableCopy];
    do {
        repeat = NO;
        int length = [copy count];
        for(int i = 0; i<length; i++) {
            current = [copy objectAtIndex:i];
            int quotes = [[current componentsSeparatedByString:@"\""] count]-1; //number of quotes
            if(quotes%2) { // if odd, merge with the next string value
                merged = [current stringByAppendingFormat:@"%@%@",separator,[copy objectAtIndex:i+1]];
                [copy replaceObjectAtIndex:i withObject:merged];
                [copy removeObjectAtIndex:i+1];
                repeat = YES;
                length = [copy count];
                break;
            }
        }
        if(!repeat) 
            break;
    } while (YES);
        
    return copy;
}

-(NSMutableArray *) fixDoubleQuotationsWhileParsingLine:(NSMutableArray *) values {
    NSString *current;
    for(int i = 0; i<[values count]; i++) {
        
        current = [values objectAtIndex:i];
        if([[current componentsSeparatedByString:@","] count ] >1){ //if commas in the token data, , get rid of the enclosing quotes
            NSRange range = NSMakeRange(1, [current length]-2);           
            current = [current substringWithRange:range];
        }
        if([current length]>1) { //now replace all two double quote(s) with one.
            [values replaceObjectAtIndex:i withObject:[current stringByReplacingOccurrencesOfString:@"\"\"" 
                                                                                         withString:@"\""]]; 
        }        
    }
    
    return values;
}

#pragma mark - Creation of CSV files

-(void) createCSVFilesFromRecords:(NSArray *)records
{
    NSMutableSet *folders = [[NSMutableSet alloc] init];
    //get the names of the folders from the array of records so you could create them
    for(Record *record in records) {
        [folders addObject:record.folder];
    }
        
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlsArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [[urlsArray objectAtIndex:0] path];
    
    //create an dictionary of filehandlers. Key - folder name, Value - FileHandler for that folder
    NSMutableDictionary *fileHandlers = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *mediaDirectories = [[NSMutableDictionary alloc] init];
    
    //for each project name, create a project folder in the documents directory with the same name. if the folder already exists, empty it. also create a media folder with the same name inside the directory
    for(NSString *newFolder in [folders allObjects]) {
        //first create the paths
        NSString *dataDirectory = [documentsDirectory stringByAppendingFormat:@"/%@",newFolder];
        NSString *mediaDirectory = [dataDirectory stringByAppendingString:@"/media"];
        [mediaDirectories setObject:mediaDirectory forKey:newFolder]; 
        NSString *dataFile = [dataDirectory stringByAppendingFormat:@"%@.csv", newFolder];
        NSError *error;
        //then create the directories...
        //create the data directory if not there already
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataDirectory]){
            [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:&error]; 
        }else {
            //If the folder already, delete it and recreate it
            [[NSFileManager defaultManager] removeItemAtPath:dataDirectory error:&error];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:&error];             
        }
        //Create the media directory
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        
        //create the file if it does not exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:dataFile]){
            NSLog(@"data file was not found, creating file");
            [[NSFileManager defaultManager] createFileAtPath: dataFile contents:nil attributes:nil];
        }
        NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:dataFile];
        [fileHandlers setObject:handler forKey:newFolder];
        
        //clear all contents of the file
        [handler truncateFileAtOffset:0]; 
        
        //write the column headings to the csv
        NSString *titles = [NSString stringWithFormat:@"Name, Type, Longitude, Latitude, Date,Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"];
        [handler writeData:[titles dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //now call the method that writes onto the array of records into their respective csv files
    [self writeRecords:(NSArray *) records withFileHandlers:(NSMutableDictionary *) fileHandlers andSaveImagesInPath:(NSMutableDictionary *) mediaDirectories];
}

-(void) writeRecords:(NSArray *) records withFileHandlers:(NSMutableDictionary *) fileHandlers andSaveImagesInPath:(NSMutableDictionary *) mediaDirectories 
{
    NSFileHandle *fileHandler;
    NSString *mediaDir;
    NSString *recordData;
    
    for(Record *record in records) {
        fileHandler = [fileHandlers objectForKey:record.folder];
        mediaDir = [fileHandlers objectForKey:record.folder];
        //now write the data contents...
        NSString *name, *type, *longitude, *latitude, *date, *time, *strike, *dip, *dipDir, *observation, *formation, *lowerFormation, *upperFormation, *trend, *plunge, *imageFileName;
        name=type=longitude=latitude=date=time=strike=dip=dipDir=observation=formation=lowerFormation=upperFormation=plunge=trend=imageFileName=@"";
        NSString *imageFilePath;
        //get all the common fields
        name = record.name;
        observation = record.fieldOservations;
        longitude = record.longitude;
        latitude = record.latitude;
        dip = [NSString stringWithFormat:@"%i", record.dip];
        dipDir = record.dipDirection;
        strike = [NSString stringWithFormat:@"%i", record.strike];
        
        //get the date and time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init]; 
        [timeFormatter setDateFormat:@"HH:mm:ss"];
        
        date = [dateFormatter stringFromDate:record.date];
        time = [timeFormatter stringFromDate:record.date];
        
        //now get the type, and type-specific fields        
        if([record isKindOfClass:[Bedding class]]) {
            type = @"Bedding";
            formation = [[(Bedding *)record  formation] formationName];
        }else if([record isKindOfClass:[Contact class]]) {
            type = @"Contact";
            lowerFormation = [[(Contact*)record lowerFormation] formationName];
            upperFormation = [[(Contact*)record upperFormation] formationName];
        }else if([record isKindOfClass:[JointSet class]]) {
            type = @"Joint Set";
            formation = [[(JointSet *)record formation] formationName];
        }else if([record isKindOfClass:[Fault class]]) {
            type = @"Fault";
            formation = [[(Fault *)record formation] formationName];
            plunge = [(Fault *)record plunge];
            trend = [(Fault *)record trend];
        }else if([record isKindOfClass:[Other class]]) {
            type = @"Other";
        }       
        
        //save the image file        
        if(record.image) {
            imageFileName = [NSString stringWithFormat:@"%@_%@.jpeg", record.folder, record.name];
            imageFilePath = [NSString stringWithFormat:@"%@/%@",imageFileName];
            if(![[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]){
                NSLog(@"image file does not exist, creating it");   
                [[NSFileManager defaultManager] createFileAtPath: imageFilePath contents:nil attributes:nil];
                
                NSFileHandle *mediaFileHandler = [NSFileHandle fileHandleForWritingAtPath:imageFilePath];
                NSData *image=UIImageJPEGRepresentation([[UIImage alloc] initWithData:record.image.imageData], 1.0);
                [mediaFileHandler writeData:image];
                [mediaFileHandler closeFile];
            }
        }
        
        //finally write the string tokens to the csv file
        recordData = [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\"\r\n",
                      name,type,longitude,latitude,date,time,strike,dip,dipDir,observation,formation,lowerFormation,upperFormation,trend,plunge,imageFileName];
        [fileHandler writeData:[recordData dataUsingEncoding:NSUTF8StringEncoding]];        
    }
    //close all the filehandlers
    for(NSFileHandle *handler in [fileHandlers allValues]) {
        [handler closeFile];
    }
}

-(void) createCSVFilesFromFormations:(NSArray *)formations 
{
    NSMutableDictionary *folders = [[NSMutableDictionary alloc] init]; //a multiset type data structure. Key-foldername; Value-array of formations for that forlder
    for(Formation *formation in formations) {
        //if the folder name has already been encountered, add to it
        if([[folders allKeys] containsObject:formation.formationFolder.folderName]) { 
            NSMutableArray *formationArray = [folders objectForKey:formation.formationFolder.folderName];
            [folders removeObjectForKey:formation.formationFolder.folderName];
            [formationArray addObject:formation.formationName];
            [folders setValue:formationArray forKey:formation.formationFolder.folderName];
        }else {
            //otherwise create a new array and add to the dictionary with the foldername as the key to that array
            NSMutableArray *formationArray = [[NSMutableArray alloc] initWithObjects:formation.formationName, nil];
            [folders setValue:formationArray forKey:formation.formationFolder.folderName];
        }
    }
    
    
}
//-(void)writeFormations:(NSDictionary *)formations

@end
