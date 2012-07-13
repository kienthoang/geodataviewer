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


@interface IEEngine()

@property (nonatomic, strong) NSArray *selectedFilePaths;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSMutableArray *formations;

@end

@implementation IEEngine

@synthesize handler=_handler;
@synthesize selectedFilePaths=_selectedFilePaths;
@synthesize records=_records;
@synthesize formations=_formations;


#pragma mark - getters for instance variables
-(NSMutableArray *) projects {
    if(!_records) _records = [[NSMutableArray alloc] init];
    return _records;
}

-(NSMutableArray *) formationFolders {
    if(!_formations) _formations = [[NSMutableArray alloc] init];
    return _formations;
}

#pragma mark - Reading of Record Files
/*
 Column Headings:
 "Name, Type, Longitude, Latitude, Date&Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"
 */
-(void) createRecordsFromCSVFiles:(NSArray *) files
{   
    
    //enum for columnHeadings
    typedef enum columnHeadings{Name, Type, Longitude, Latitude, dateAndTime, Strike, Dip, dipDirection, Observations, Formation, lowerFormation, upperFormation, Trend, Plunge, imageName}columnHeadings;   
    
    //get paths to the selected files
    self.selectedFilePaths = [self getSelectedFilePaths:files];
    
    for(NSString *path in self.selectedFilePaths) {//for each file
        //this is an array of array
        NSMutableArray *lineRecordsInAFile = [[self getRecordsFromFile:path] mutableCopy];
        //remove the first line which is simply the column headings
        [lineRecordsInAFile removeObjectAtIndex:0];
        //now create transient objects from the rest
        
        for(id lineArray in lineRecordsInAFile) { //for each line in file, i.e. each single record
            
            if([lineArray count]!=15){ //not enough/more fields in the record
                NSLog(@"Corrupted record ignored!");
                continue;
            }
            TransientRecord *record;
            //identify the record type and populate record specific fields
            if([[lineArray objectAtIndex:1] isEqualToString:@"Contact"]) {
                record =[[TransientContact alloc] init];
                [(TransientContact *)record setLowerFormation:[lineArray objectAtIndex:lowerFormation]];
                [(TransientContact *)record setUpperFormation:[lineArray objectAtIndex:upperFormation]];
            }else if ([[lineArray objectAtIndex:1] isEqualToString:@"Bedding"]) {
                record = [[TransientBedding alloc] init];
                [(TransientBedding *)record setFormation:[lineArray objectAtIndex:Formation]];
            }else if([[lineArray objectAtIndex:1] isEqualToString:@"Joint Set"]) {
                record = [[TransientJointSet alloc] init]; 
                [(TransientJointSet *)record setFormation:[lineArray objectAtIndex:Formation]];
            }else if([[lineArray objectAtIndex:1] isEqualToString:@"Fault"]) {
                record = [[TransientFault alloc] init]; 
                [(TransientFault *)record setPlunge:[lineArray objectAtIndex:Plunge]];
                [(TransientFault *)record setTrend:[lineArray objectAtIndex:Trend]];
                [(TransientFault *)record setFormation:[lineArray objectAtIndex:Formation]];
            }else if([[lineArray objectAtIndex:1] isEqualToString:@"Other"]) {
                record = [[TransientOther alloc] init];            
            }
            
            //now populate the common fields for all the records
            record.name = [lineArray objectAtIndex:Name];
            record.dip = [lineArray objectAtIndex:Dip];
            record.dipDirection = [lineArray objectAtIndex:dipDirection];
            record.fieldOservations = [lineArray objectAtIndex:Observations];
            record.latitude = [lineArray objectAtIndex:Latitude];
            record.longitude = [lineArray objectAtIndex:Longitude];
            record.strike = [lineArray objectAtIndex:Strike];
            
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
            
            if([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]){
                NSString* content = [NSString stringWithContentsOfFile:imageFilePath encoding:NSUTF8StringEncoding error:nil];
                //now set the image content
                record.image.imageData = [content dataUsingEncoding:NSUTF8StringEncoding];
                //imageHashData not saved. is it needed?
            }
            
            //add the record to the arra of records
            [self.records addObject:record];
        }        
    }    
    //now call the handler and pass it the array of records created ... 
    if(self.handler) [self.handler handleConflictsForArray:self.formations];
}


#pragma mark - Reading of Formation files
-(void) createFormationsFromCSVFiles:(NSArray *) files
{
    //get the complete file paths for the selected files that exist
    self.selectedFilePaths=[self getSelectedFilePaths:files];
    
    //read each of those files line by line and create the formation objects and add it to self.formations array.
    for(NSString *path in self.selectedFilePaths) {
        //this is an array lines, which is an array of tokens
        NSMutableArray *lineRecordsInAFile = [[self getRecordsFromFile:path] mutableCopy];
        //for each array of tokens 
        for(NSMutableArray *record in lineRecordsInAFile) {
            NSString *folder = [record objectAtIndex:0];
            [record removeObjectAtIndex:0];
            TransientFormation_Folder *newFormationFolder = [[TransientFormation_Folder alloc] init];
            newFormationFolder.folderName = folder;
            //for each token(formation) in such an array of line record(formation folder)
            for(NSString *formation in  record) {
                TransientFormation *newFormation = [[TransientFormation alloc] init];
                newFormation.formationFolderName = folder;
                newFormation.formationName = formation;
                [self.formations addObject:newFormation];
            }
        }
    }
    //now call the conflict handler to take care of writing these to the database
    if(self.handler) [self.handler handleConflictsForArray:self.formations];
    
}

#pragma mark - CSV File Parsing
-(NSArray *) getRecordsFromFile:(NSString *) filePath
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
    
    for(NSString *line in allLines) {//skip the first line
        [records addObject:[self parseLine:line]];
    }
        
    return records;

}

-(NSArray *)getSelectedFilePaths:(NSArray *) fileNames;
{   
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathsArray objectAtIndex:0];
    
    for(NSString *file in fileNames) {
        [paths addObject:[documentsDirectory stringByAppendingFormat:@"/%@",file]];
    }
    
    return paths;
}

-(NSArray *) parseLine:(NSString *) line 
{
    //log to see if each individual line (record) is extracted properly
        NSLog(@"Individual record: %@", line);
    
    NSMutableArray *values = [[line componentsSeparatedByString:@","] mutableCopy];

    values = [self separateRecordsOrFieldsByCountingQuotations:values];
    
    [self fixDoubleQuotationsWhileParsingLine:values];
    
    return values;
}
-(NSMutableArray *) fixNewLineCharactersInData:(NSArray *)records {
    return [self separateRecordsOrFieldsByCountingQuotations:records];
}

-(NSMutableArray *) separateRecordsOrFieldsByCountingQuotations:(NSArray *) array {
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
                merged = [current stringByAppendingFormat:@",%@",[copy objectAtIndex:i+1]];
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
        if([current length]>1) {
            [values replaceObjectAtIndex:i withObject:[current stringByReplacingOccurrencesOfString:@"\"\"" 
                                                                                         withString:@"\""]]; 
        }        
    }
    return values;
}
@end
