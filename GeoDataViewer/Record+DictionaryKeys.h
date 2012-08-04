//
//  Record+DictionaryKeys.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/23/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Record.h"

@interface Record (DictionaryKeys)

//These are the (arbitrary) macro-defined keys for the dictionary that contains the user-modified information of a record
#define RECORD_NAME @"GDV.Record.RecordName"
#define RECORD_TYPE @"GDV.Record.RecordType"
#define RECORD_LATITUDE @"GDV_Record_Latitude"
#define RECORD_LONGITUDE @"GDV_Record_Longitude"
#define RECORD_DATE @"GDV_Record_Date"
#define RECORD_TIME @"GDV_Record_Time"
#define RECORD_STRIKE @"GDV_Record_Strike"
#define RECORD_FORMATION @"GDV_Record_Formation"
#define RECORD_UPPER_FORMATION @"GDV_Record_Upper_Formation"
#define RECORD_LOWER_FORMATION @"GDV_Record_Lower_Formation"
#define RECORD_TREND @"GDV_Record_Trend"
#define RECORD_PLUNGE @"GDV_Record_Plunge"
#define RECORD_DIP @"GDV_Record_Dip"
#define RECORD_DIP_DIRECTION @"GDV_Record_Dip_Direction"
#define RECORD_FIELD_OBSERVATION @"GDV_Field_Observation"

//added for record image
#define RECORD_IMAGE_DATA @"GDV_Record_Image_Data"

@end
