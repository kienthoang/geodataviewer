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
typedef enum columnHeadings{Name, Type, Longitude, Latitude, dateAndTime, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

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
    NSString *date = [lineArray objectAtIndex:dateAndTime];
    //remove leading and trailing spaces
    date = [date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    date = [date stringByReplacingOccurrencesOfString:@"," withString:@""]; //remove comma(s), if any
    NSArray *array = [date componentsSeparatedByString:@" "]; //separate by spaces
    
    typedef enum Months{Zero, January, February, March, April, May, June, July, August, September, October, November, December}Months; 
    int month = (Months)[array objectAtIndex:1];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[[array objectAtIndex:3] intValue]];
    [comps setMonth:month];
    [comps setDay:[[array objectAtIndex:2] intValue]];
    NSArray *time = [[array objectAtIndex:4] componentsSeparatedByString:@":"];
    [comps setHour:[[time objectAtIndex:0] intValue]];
    [comps setMinute:[[time objectAtIndex:1] intValue]];
    [comps setSecond:[[time objectAtIndex:2] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *newDate = [gregorian dateFromComponents:comps];    
    //finally populate the date field
    record.date = newDate;
    
    
    //separate the date&time string to populate the date and time strings in the transient records
    NSArray *dateTimeArray = [[lineArray objectAtIndex:dateAndTime] componentsSeparatedByString:@","];
    record.dateString = [NSString stringWithFormat:@"%@,%@",[dateTimeArray objectAtIndex:0],[dateTimeArray      objectAtIndex:1]];
    record.timeString = [dateTimeArray objectAtIndex:2];
    
    //to set the image, first get the image from the images directory
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsArray objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingFormat:@"/images/%@", [lineArray objectAtIndex:imageName]];
    
    //Set the image
    if([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]){
        NSString* content = [NSString stringWithContentsOfFile:imageFilePath encoding:NSUTF8StringEncoding error:nil];
        //now set the image content
        record.image.imageData = [content dataUsingEncoding:NSUTF8StringEncoding];
        //imageHashData not saved. is it needed?
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
        
        if(lineArray.count!=NUMBER_OF_COLUMNS_PER_RECORD_LINE) //not enough/more fields in the record
            NSLog(@"Corrupted record ignored!");
        
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
 "Name, Type, Longitude, Latitude, Date&Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"
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
                                   andFolders:self.folders 
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
        
        //for each token(formation) in such an array of line record(formation folder)
        for(NSString *formation in  record) {
            //if the formation name is not empty
            if (formation.length) {
                TransientFormation *newFormation = [[TransientFormation alloc] init];
                newFormation.formationFolder = newFormationFolder;
                newFormation.formationName = formation;
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
    NSString *merged;
    NSString *current;
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
    }while (YES);
    
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
@end
