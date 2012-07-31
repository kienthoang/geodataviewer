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
#define RECORD_NAME @"GeoFieldBook_Record_Name"
#define RECORD_LATITUDE @"GeoFieldBook_Record_Latitude"
#define RECORD_LONGITUDE @"GeoFieldBook_Record_Longitude"
#define RECORD_DATE @"GeoFieldBook_Record_Date"
#define RECORD_TIME @"GeoFieldBook_Record_Time"
#define RECORD_STRIKE @"GeoFieldBook_Record_Strike"
#define RECORD_FORMATION @"GeoFieldBook_Record_Formation"
#define RECORD_UPPER_FORMATION @"GeoFieldBook_Record_Upper_Formation"
#define RECORD_LOWER_FORMATION @"GeoFieldBook_Record_Lower_Formation"
#define RECORD_TREND @"GeoFieldBook_Record_Trend"
#define RECORD_PLUNGE @"GeoFieldBook_Record_Plunge"
#define RECORD_DIP @"GeoFieldBook_Record_Dip"
#define RECORD_DIP_DIRECTION @"GeoFieldBook_Record_Dip_Direction"
#define RECORD_FIELD_OBSERVATION @"GeoFieldBook_Field_Observation"

//added for record image
#define RECORD_IMAGE_DATA @"GeoFieldBook_Record_Image_DATA"

@end
