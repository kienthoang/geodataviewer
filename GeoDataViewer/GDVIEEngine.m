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

#import "GeoDatabaseManager.h"
#import "Group.h"
#import "Group+DictionaryKeys.h"
#import "Group+Creation.h"
#import "Record.h"
#import "Record+Creation.h"
#import "Folder.h"
#import "Folder+Creation.h"
#import "Folder+DictionaryKeys.h"
#import "Formation.h"

#import "Group+Modification.h"

#import "Formation_Folder.h"
#import "Formation_Folder+Creation.h"
#import "Formation_Folder+Modification.h"

#import "Formation.h"
#import "Formation+Creation.h"
#import "Formation+DictionaryKeys.h"

#import "Response_Record+Creation.h"
#import "Answer+Creation.h"
#import "Answer+DateFormatter.h"

@interface GDVIEEngine()

@property (nonatomic, strong) NSMutableDictionary *groupDictionaryByID;
@property (nonatomic, strong) ValidationMessageBoard *validationMessageBoard;

@end

@implementation GDVIEEngine

@synthesize database=_database;
@synthesize delegate=_delegate;

@synthesize validationMessageBoard=_validationMessageBoard;
@synthesize groupDictionaryByID=_groupDictionaryByID;

typedef void (^database_save_t)(UIManagedDocument *database);

- (void)saveDatabaseWithCompletionHandler:(database_save_t)completionHandler {
    [self.database saveToURL:self.database.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success)
            completionHandler(self.database);
        else
            NSLog(@"Failed to save changes to database!");
    }];
}

typedef void (^database_t)(void);

- (void)performDatabaseBlock:(database_t)block {
    [self.database.managedObjectContext performBlock:block];
}

- (void)reset {
    //Reset states
    self.groupDictionaryByID=[NSMutableDictionary dictionary];
    self.validationMessageBoard=[[ValidationMessageBoard alloc] init];
}

//enum for columnHeadings
typedef enum columnHeadings{Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

#pragma mark - Getters
-(UIManagedDocument *) database {
    if(!_database)
        _database = [GeoDatabaseManager standardDatabaseManager].mainDatabase;
    return _database;
}

-(NSMutableDictionary *) groupDictionaryByID {
    if(!_groupDictionaryByID) {
        _groupDictionaryByID = [NSMutableDictionary dictionary];
    }
    return _groupDictionaryByID;
}

- (ValidationMessageBoard *)validationMessageBoard {
    if (!_validationMessageBoard)
        _validationMessageBoard=[[ValidationMessageBoard alloc] init];
    
    return _validationMessageBoard;
}

#pragma mark - database query

-(Formation_Folder *) queryDatabaseForFormationFolderWithName:(NSString *) name {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Formation_Folder"];
    request.predicate = [NSPredicate predicateWithFormat:@"folderName=%@",name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey: @"folderName" ascending:YES]];
    NSArray *results=[self.database.managedObjectContext executeFetchRequest:request error:NULL];
    
    //if there is any such formation folder fetched, return it
    return results.count>0 ? [results lastObject] : nil;                               
}

#pragma mark - Data Managers

- (NSDate *)dateFromDateToken:(NSString *)dateToken andTimeToken:(NSString *)timeToken {
    NSLog(@"Date token: %@ Time token: %@",dateToken,timeToken);
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
            [studentGroup removeAndDeleteAllFolders];
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
    [self performDatabaseBlock:^{
        //get paths to the selected files
        NSArray *selectedPaths = [self getSelectedFilePaths:files];
        //Iterate through each csv files and create records from each of them
        for (NSString *path in selectedPaths) {
            //Construct the records
            [self constructRecordsFromCSVFileWithPath:path];
        }
        
        //Save to database
        [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){
            //Notify the delegate that the importing was finished
            [self.delegate engineDidFinishProcessingRecords:self];
        }];
        
        //Reset
        [self reset];
    }];
}

#pragma mark - Reading of Student Response CSV Files

typedef enum responseHeadings {QuestionPrompt,ResponseContent,ResponseDate,ResponseTime,ResponseLatitude,ResponseLongitude,NumberOfRecords} responseHeadings;

- (void)createStudentResponsesFromCSVFiles:(NSArray *)files {
    [self performDatabaseBlock:^(void){
        NSArray *selectedPaths = [self getSelectedFilePaths:files];    
        
        //read each of those files line by line and create the student response objects
        for(NSString *path in selectedPaths) {
            //Construct student responses from the file path
            [self constructStudentResponsesFromFilePath:path];
        }
        
        //now save the managedObjectcontext permanently in the database
        [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){
            //post some notification to the delegate that the database was updated
            [self.delegate engineDidFinishProcessingStudentResponses:self];
        }];
        
        //Reset
        [self reset];
    }];
}

- (void)constructStudentResponsesFromFilePath:(NSString *)path {
    //Get all the token arrays, each of them corresponding to a line in the csv file)
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy;
    
    if([[[tokenArrays objectAtIndex:0] objectAtIndex:0] isEqualToString:METADATA_HEADER]) {
        //Get the group from the metadata info
        NSString *groupName=[[tokenArrays objectAtIndex:1] objectAtIndex:1];
        NSString *groupID=[[tokenArrays objectAtIndex:2] objectAtIndex:1];
        NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
        int numResponses=[numberFormatter numberFromString:[[tokenArrays objectAtIndex:3] objectAtIndex:1]].intValue;
        NSNumber *faulty=[NSNumber numberWithBool:NO];
        
        //Try to get the student group from the student-group-by-id dictionary
        Group *studentGroup=[self.groupDictionaryByID objectForKey:groupID];
        
        //If it does not exist, create a new one and erase all of its responses
        if (!studentGroup) {
            NSDictionary *groupInfo=[NSDictionary dictionaryWithObjectsAndKeys:groupName,GDVStudentGroupName,groupID,GDVStudentGroupIdentifier,faulty,GDVStudentGroupIsFaulty, nil];
            studentGroup=[Group studentGroupForInfo:groupInfo inManagedObjectContext:self.database.managedObjectContext];
            [self.groupDictionaryByID setObject:studentGroup forKey:groupID];
            [studentGroup removeAndDeleteAllStudentResponses];
        }
        
        //Remove the metadata token arrays and the response header token array
        NSIndexSet *indexes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)];
        [tokenArrays removeObjectsAtIndexes:indexes];
        
        //Loop through the token arrays and create responses
        int responseCounter=0;
        Response_Record *responseRecord=nil;
        for (NSArray *tokenArray in tokenArrays) {
            if (!responseCounter++) {
                responseRecord=[Response_Record responseRecordInManagedObjectContext:self.database.managedObjectContext];
                responseRecord.group=studentGroup;
            }
            
            //Reset counter if necessary
            if (responseCounter==numResponses)
                responseCounter=0;
                
            //Create a new response
            [self studentResponseForTokenArray:tokenArray andResponseRecord:responseRecord];
        }
    }
}

- (Answer *)studentResponseForTokenArray:(NSArray *)tokenArray andResponseRecord:(Response_Record *)responseRecord {
    Answer *response=nil;
    
    //Create an info dictionary from the info in the token array
    NSMutableDictionary *responseDictionary=[NSMutableDictionary dictionary];
    [responseDictionary setObject:[tokenArray objectAtIndex:QuestionPrompt] forKey:GDVStudentResponseQuestionPrompt];
    [responseDictionary setObject:[tokenArray objectAtIndex:ResponseContent] forKey:GDVStudentResponseContent];
    
    NSNumberFormatter *numberFormatter=[[NSNumberFormatter alloc] init];
    [responseDictionary setObject:[numberFormatter numberFromString:[tokenArray objectAtIndex:ResponseLatitude]] forKey:GDVStudentResponseLatitude];
    [responseDictionary setObject:[numberFormatter numberFromString:[tokenArray objectAtIndex:ResponseLongitude]] forKey:GDVStudentResponseLongitude];
    [responseDictionary setObject:[numberFormatter numberFromString:[tokenArray objectAtIndex:NumberOfRecords]] forKey:GDVStudentResponseNumRecords];
    [responseDictionary setObject:responseRecord forKey:GDVStudentResponseResponseRecord];
    
    NSString *dateToken = [[tokenArray objectAtIndex:ResponseDate] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *timeToken = [[tokenArray objectAtIndex:ResponseTime] stringByReplacingOccurrencesOfString:@" " withString:@""];
    [responseDictionary setObject:[self dateFromDateToken:dateToken andTimeToken:timeToken] forKey:GDVStudentResponseDate];
    
    response=[Answer responseForInfo:responseDictionary inManagedObjectContext:self.database.managedObjectContext];
    
    return response;
}

#pragma mark - Reading of Formation files

///* The format of this file would be two columns of data in a file for each formation folder. The first column is the formation type and the second would be the color associated with that formation type. If the color column is empty, the color would be default when the annotations are drawn.
// For example:
// 
// Formations  Color  -> Column headings
// Formation1  Red
// Formation2  Blue
// ...         ...
// */
- (void)createFormationsWithColorFromCSVFiles:(NSArray *)files 
{    
    [self performDatabaseBlock:^(void){
        NSArray *selectedPaths = [self getSelectedFilePaths:files];    
        
        //read each of those files line by line and create the formation objects and add it to self.formations array.
        for(NSString *path in selectedPaths) {
            //Construct formations from the file path
            NSString *folderName = [[[path componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."] objectAtIndex:0];
            [self constructFormationsWithColorsByParsingFilePath:path andFolderName:folderName];
        }
        
        //now save the managedObjectcontext permanently in the database
        [self saveDatabaseWithCompletionHandler:^(UIManagedDocument *database){
            //post some notification to the delegate that the database was updated
            [self.delegate engineDidFinishProcessingFormations:self];
        }];
        
        //Reset
        [self reset];
    }];
}
-(void) constructFormationsWithColorsByParsingFilePath:(NSString *) path andFolderName:(NSString *) fileName 
{
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy;// A 2D array with rows as each line, and tokens in each line as the columns in each row   

    //Get the formation folder
    Formation_Folder *formationFolder=[Formation_Folder formationFolderForName:fileName inManagedObjectContext:self.database.managedObjectContext];    
    [formationFolder removeAndDeleteAllFormations];
        
    //now read the rest of the tokens and create Formation objects and add pointers to the folder inside that objects
    [tokenArrays removeObjectAtIndex:0];//get rid of the column headings
    if(!tokenArrays.count) return; //return if no data in the file
    
    int sortNumber = 1;
    for (int line = 0; line<tokenArrays.count; line++) {
        NSMutableArray * formationTokens = [tokenArrays objectAtIndex:line];
        NSString  *formationName = [TextInputFilter filterDatabaseInputText:[formationTokens objectAtIndex:0]];
        NSString *formationColor = [TextInputFilter filterDatabaseInputText:[formationTokens objectAtIndex:1]];
        
        //if the name is not empty
        if(formationName.length) {
            NSMutableDictionary *formationInfo=[NSMutableDictionary dictionary];
            [formationInfo setObject:formationName forKey:GeoFormationName];
            [formationInfo setObject:formationColor forKey:GeoFormationColorName];
            [formationInfo setObject:[[ColorManager standardColorManager] colorWithName:formationColor] forKey:GeoFormationColor];
            [formationInfo setObject:[NSNumber numberWithInt:sortNumber++] forKey:GeoFormationSortIndex];
            
            //finally create a new entity
            Formation *formation=[Formation formationForInfo:formationInfo inManagedObjectContext:self.database.managedObjectContext];
            formation.formationFolder=formationFolder;
        }                                                            
    }
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
    NSMutableArray *copy = array.mutableCopy;
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
