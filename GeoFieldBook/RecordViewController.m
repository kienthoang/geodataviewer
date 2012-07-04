//
//  RecordViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonDigest.h>

#import "TextInputFilter.h"

#import "Record.h"
#import "Image+Creation.h"
#import "RecordViewController.h"
#import "Record+Modification.h"
#import "Record+Validation.h"
#import "Record+NameEncoding.h"
#import "Formation.h"
#import "Bedding.h"
#import "Contact.h"
#import "JointSet.h"
#import "JointSet+Description.h"
#import "Fault.h"
#import "Other.h"

#import "FormationFolderTableViewController.h"
#import "GeoDatabaseManager.h"

#import "StrikePickerViewController.h"
#import "DipPickerViewController.h"
#import "DipDirectionPickerViewController.h"
#import "PlungePickerViewController.h"
#import "TrendPickerViewController.h"
#import "FormationPickerViewController.h"

#import "Image+Creation.h"

#import "MKGeoRecordAnnotation.h"

@interface RecordViewController() <UINavigationControllerDelegate,CLLocationManagerDelegate, StrikePickerDelegate,DipPickerDelegate,DipDirectionPickerDelegate,PlungePickerDelegate,TrendPickerDelegate,FormationPickerDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate>

//The names of the pickers
#define FORMATION_PICKER_NAME @"RecordViewController.Formation_Picker"
#define LOWER_FORMATION_PICKER_NAME @"RecordViewController.Lower_Formation_Picker"
#define UPPER_FORMATION_PICKER_NAME @"RecordViewController.Upper_Formation_Picker"

- (void)userDoneEditingRecord;         //handles when user finishes editing the record's info
- (void)resignAllTextFieldsAndAreas;

#pragma mark - Validation Mechanism Declarations

- (BOOL)validateMandatoryFieldsOfInfo:(NSDictionary *)recordInfo 
                        alertsEnabled:(BOOL)alertsEnabled;

#pragma mark - Form Setup Controller Method Declarations

- (void)formSetupForBeddingType;
- (void)formSetupForContactType;
- (void)formSetupForJointSetType;
- (void)formSetupForFaultType;
- (void)formSetupForOtherType;

- (void)updateFormForRecord:(Record *)record;

#pragma mark - Private Properties

@property (nonatomic) BOOL editing;
@property (nonatomic,readonly) NSArray *textFields;
@property (nonatomic, strong) CLLocationManager *locationManager; 
@property (nonatomic, strong) NSTimer *gpsTimer;
@property (nonatomic,strong) NSDate *acquiredDate;
@property (nonatomic,weak) UIImage *acquiredImage;
@property (nonatomic) BOOL hasTakenImage;

@property (weak, nonatomic) UIPopoverController *formationFolderPopoverController;

#pragma mark - Non-interactive UI Elements

@property (weak,nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *gatheringGPS; 
@property (nonatomic, strong) UIPopoverController *imagePopover;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

#pragma mark - Buttons

@property (weak, nonatomic) IBOutlet UIButton *browseButton;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *acquireButton;
@property (weak, nonatomic) UIButton *imagePickerPresenter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *masterPresenter;

#pragma mark - Form Input Fields

@property (weak, nonatomic) IBOutlet UITextField *recordNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextField *strikeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipTextField;
@property (weak, nonatomic) IBOutlet UITextField *formationTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipDirectionTextField;
@property (weak, nonatomic) IBOutlet UITextField *upperFormationTextField;
@property (weak, nonatomic) IBOutlet UITextField *lowerFormationTextField;
@property (weak, nonatomic) IBOutlet UITextField *trendTextField;
@property (weak, nonatomic) IBOutlet UITextField *plungeTextField;

@property (weak, nonatomic) IBOutlet UITextView *fieldObservationTextArea;

#pragma mark - Form Labels

@property (weak, nonatomic) IBOutlet UILabel *recordTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *formationLabel;
@property (weak, nonatomic) IBOutlet UILabel *strikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *trendLabel;
@property (weak, nonatomic) IBOutlet UILabel *plungeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerFormationLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperFormationLabel;
@property (weak, nonatomic) IBOutlet UILabel *fieldObservationLabel;

@end

@implementation RecordViewController

@synthesize scrollView = _scrollView;

@synthesize locationManager = _locationManager;
@synthesize gpsTimer = _gpsTimer;
@synthesize gatheringGPS = _gatheringGPS;
@synthesize editButton = _editButton;
@synthesize acquiredImage=_acquiredImage;
@synthesize hasTakenImage=_hasTakenImage;

@synthesize formationFolderPopoverController=_formationFolderPopoverController;

@synthesize record=_record;
@synthesize imageView = _imageView;
@synthesize recordTypeLabel = _recordTypeLabel;
@synthesize recordNameTextField = _recordNameTextField;
@synthesize latitudeTextField = _latitudeTextField;
@synthesize longitudeTextField = _longitudeTextField;
@synthesize dateTextField = _dateTextField;
@synthesize timeTextField = _timeTextField;
@synthesize strikeTextField = _strikeTextField;
@synthesize dipTextField = _dipTextField;
@synthesize dipDirectionTextField = _dipDirectionTextField;
@synthesize dipLabel = _dipLabel;
@synthesize formationTextField = _formationTextField;
@synthesize dipDirectionLabel = _dipDirectionLabel;
@synthesize trendLabel = _trendLabel;
@synthesize trendTextField = _trendTextField;
@synthesize plungeLabel = _plungeLabel;
@synthesize plungeTextField = _plungeTextField;
@synthesize lowerFormationLabel = _lowerFormationLabel;
@synthesize lowerFormationTextField = _lowerFormationTextField;
@synthesize upperFormationLabel = _upperFormationLabel;
@synthesize upperFormationTextField = _upperFormationTextField;
@synthesize fieldObservationLabel = _fieldObservationLabel;
@synthesize acquireButton = _acquireButton;
@synthesize fieldObservationTextArea = _fieldObservationTextArea;
@synthesize formationLabel = _formationLabel;
@synthesize strikeLabel = _strikeLabel;

@synthesize editing=_editing;

@synthesize toolbar=_toolbar;

@synthesize delegate=_delegate;

@synthesize browseButton = _browseButton;
@synthesize takePhotoButton = _takePhotoButton;
@synthesize imagePopover = _imagePopover;
@synthesize imagePickerPresenter=_imagePickerPresenter;
@synthesize masterPresenter = _masterPresenter;

@synthesize acquiredDate=_acquireDate;

@synthesize masterPopoverController=_masterPopoverController;

#pragma mark - Getters and Setters

- (void)setRecord:(Record *)record {
    //If the previous record is not nil, show an autosave alert
    //If self is still in editing mode and the delegate has not been kicked off the anvigation stack, notify the delegate before going off screen
    if (self.record && self.editing && self.delegate) 
    {
        //Notify the delegate of the changes in the record info
        [self.delegate userDidNavigateAwayFrom:self 
                          whileModifyingRecord:self.record 
                             withNewRecordInfo:[self dictionaryFromForm]];
        
        //End editing mode
        [self setEditing:NO animated:YES];
    }
    
    _record=record;
    
    //Update the text fields and labels
    [self updateFormForRecord:self.record];
    
    [self.view setNeedsDisplay];
}

- (NSArray *)textFields {
    return [NSArray arrayWithObjects:self.recordNameTextField,self.strikeTextField,self.dipTextField,self.dipDirectionTextField,self.formationTextField,self.trendTextField,self.plungeTextField,self.lowerFormationTextField,self.upperFormationTextField, nil];
}

- (BOOL)isInEdittingMode {
    return self.editing;
}

#pragma mark - Helpers

//Resign all text fields and text areas
- (void)resignAllTextFieldsAndAreas {
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
    [self.fieldObservationTextArea resignFirstResponder];
}

#pragma mark - Form Information Extractors and Processors

- (void)dictionary:(NSMutableDictionary *)dictionary 
         setObject:(id)object 
            forKey:(NSString *)key 
{
    //Insert the object-key pair into the dictionary if the object is not nil
    if (object)
        [dictionary setObject:object forKey:key];
}

//Creates and returns the user-modified info dictionary
- (NSDictionary *)dictionaryFromForm {
    //Create a NSDictionary with the user-modified information
    NSMutableDictionary *recordDictionary=[NSMutableDictionary dictionary];
    
    //Start inserting user-modified information into the dictionary using the custom method (to avoid inserting nil)
    [self dictionary:recordDictionary setObject:self.latitudeTextField.text forKey:RECORD_LATITUDE];
    [self dictionary:recordDictionary setObject:self.longitudeTextField.text forKey:RECORD_LONGITUDE];
    [self dictionary:recordDictionary setObject:self.acquiredDate forKey:RECORD_DATE];

    [self dictionary:recordDictionary setObject:self.recordNameTextField.text forKey:RECORD_NAME];
    [self dictionary:recordDictionary setObject:self.strikeTextField.text forKey:RECORD_STRIKE];
    [self dictionary:recordDictionary setObject:self.dipTextField.text forKey:RECORD_DIP];
    [self dictionary:recordDictionary setObject:self.dipDirectionTextField.text forKey:RECORD_DIP_DIRECTION];
    [self dictionary:recordDictionary setObject:self.formationTextField.text forKey:RECORD_FORMATION];
    [self dictionary:recordDictionary setObject:self.fieldObservationTextArea.text forKey:RECORD_FIELD_OBSERVATION];
    
    //Specific update for specific of records
    [self dictionary:recordDictionary setObject:self.plungeTextField.text forKey:RECORD_PLUNGE];
    [self dictionary:recordDictionary setObject:self.trendTextField.text forKey:RECORD_TREND];
    [self dictionary:recordDictionary setObject:self.lowerFormationTextField.text forKey:RECORD_LOWER_FORMATION];
    [self dictionary:recordDictionary setObject:self.upperFormationTextField.text forKey:RECORD_UPPER_FORMATION];
    
    //Insert the image data
     NSData *imageData=self.acquiredImage ? UIImageJPEGRepresentation(self.acquiredImage,0.2) : nil;
    [self dictionary:recordDictionary setObject:imageData forKey:RECORD_IMAGE_DATA];
    
    return recordDictionary;
}

- (void)userDoneEditingRecord {
    //Send the dictionary info to the delegate for updating
    [self.delegate recordViewController:self 
                    userDidModifyRecord:self.record 
                      withNewRecordInfo:[self dictionaryFromForm]];
    
    //FOR PERFORMANCE OPTIMIZATION
    //nillify acquired data, in case the user continues to modify the same record (self does not go off the navitation stack yet)
    self.acquiredImage=nil;
}

#pragma mark - Location-based Information Processors

-(void) setUpLocationManager {
    [self.gatheringGPS setHidesWhenStopped:YES];
    self.locationManager = [[CLLocationManager alloc] init];
    if(!self.locationManager) NSLog(@"initialized here");
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone; 
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; //accuracy in 100 meters 
    
    //stop the location manager
    [self.locationManager stopUpdatingHeading];
}

- (IBAction)acquireData:(UIBarButtonItem *)sender {    
    //Only acquire data when self is in editing mode
    if (self.editing) {
        //Save the acquired date
        self.acquiredDate=[[NSDate alloc] init];
        
        //reset the txtfields appropriately.
        self.dateTextField.text = [Record dateFromNSDate:self.acquiredDate];
        self.timeTextField.text = [Record timeFromNSDate:self.acquiredDate]; 
        
        //update the location. 
        //this will return immediatley and notifies the delegate with locationmanager:didupdate... 
        [self.locationManager startUpdatingLocation];
        
        //Set up the timer to respond every ten seconds and not to repeat. When timer is called, the locationManager is finished and the Activity Indicator is hidden
        self.gpsTimer = [NSTimer scheduledTimerWithTimeInterval:RECORD_DEFAULT_GPS_STABLILIZING_INTERVAL_LENGTH 
                                                         target:self 
                                                       selector:@selector(timerFired) 
                                                       userInfo:nil 
                                                        repeats:NO];
        [self.gatheringGPS startAnimating];
    }
}

-(void) timerFired{
    //Stop animating
    if (self.gatheringGPS.isAnimating) {
        [self.gatheringGPS stopAnimating];
        [self.locationManager stopUpdatingLocation];  
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //here, save the current location
    NSString *latitudeText = [NSString stringWithFormat:@"%3.5f", newLocation.coordinate.latitude];
    NSString *longitudeText = [NSString stringWithFormat:@"%3.5f", newLocation.coordinate.longitude];
    [self.latitudeTextField setText:latitudeText];
    [self.longitudeTextField setText:longitudeText];
    
    //then stop the delegate
    [self.locationManager stopUpdatingHeading];
    
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{    
    NSLog(@"Location grabing error %@, %@", error, [error userInfo]);
}

#pragma mark - Take Photo/Browse Handlers

- (IBAction)browsePressed:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //Setup the image picker
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        //Show the image picker as popover
        self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.imagePopover presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        //Specify user has pressed browse button
        self.imagePickerPresenter=self.browseButton;
    }
}	

#define IMAGE_IN_POPOVER YES

//Dismiss the image picker
- (void)dismissImagePicker
{	
    //Dismiss the picker if it's on screen
    if (self.imagePopover.isPopoverVisible) {
        [self.imagePopover dismissPopoverAnimated:YES];
        self.imagePopover = nil;
    }
}

- (IBAction)takePhoto:(UIButton *)sender {
    //Allow the user to take the photo if camera is available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.view.contentMode=UIViewContentModeRedraw;
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = NO;//no editing
            if (IMAGE_IN_POPOVER) {
                //Dismiss the old popover if it's still on screen
                [self dismissImagePicker];
                
                //Set up a new popover
                self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [self.imagePopover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } 
            else
                [self presentModalViewController:picker animated:YES];
        }
        
        //Set has taken image to YES (for saving later)
        self.hasTakenImage=YES;
        
        //Specify that the image picker presenter is the sender
        self.imagePickerPresenter=sender;
    }
}

//Handles when user already selected an image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{	
    //Get the image the user picked and save that in a property
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    self.acquiredImage=image;
    
    //Dismiss the image picker
    [self dismissImagePicker];
    
    //Save the photo into the photo library if the image was taken
    if (self.hasTakenImage) {
        UIImageWriteToSavedPhotosAlbum(self.acquiredImage, nil, nil, nil);
        self.hasTakenImage=NO;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //Dismiss the image picker on cancel
    [self dismissImagePicker];
}

#pragma mark - Gesture Handlers

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //dismiss the keyboard
    [self resignAllTextFieldsAndAreas];
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle the editting mode
    if (self.editing)
        [self endEditingModeAndSaveWithValidationsEnabled:YES];
    else 
        [self setEditing:YES animated:YES];
}

- (IBAction)presentMaster:(UIBarButtonItem *)sender {
    if (self.masterPopoverController) {
        //Dismiss the formation folder popover if it's visible on screen
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:NO];

        //Dismiss the keyboard
        [self resignAllTextFieldsAndAreas];
        
        //Present the master popover
        [self.masterPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];  
    }
}

#pragma mark - Form Validations

//Return NO if the info failed the validations; put up alerts if desired
- (BOOL)validateMandatoryFieldsOfInfo:(NSDictionary *)recordInfo 
                        alertsEnabled:(BOOL)alertsEnabled 
{
    //Put up alerts if validations fail
    NSArray *validationKeys=[Record validatesMandatoryPresenceOfRecordInfo:recordInfo];
    if ([validationKeys count] && alertsEnabled) {
        //Get the name of the fields that do not pass validations
        NSMutableArray *failedFieldNames=[NSMutableArray array];
        for (NSString *failedKey in validationKeys)
            [failedFieldNames addObject:[Record nameForDictionaryKey:failedKey]];
        
        //Set up the alert
        NSString *alertMessage=[NSString stringWithFormat:@"The following information is missing: %@",[failedFieldNames componentsJoinedByString:@", "]];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Invalid Information" message:alertMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Editing Mode Controllers

- (void)toggleEnableOfFormInputFields {
    //Change the style of the edit button to edit or done
    self.editButton.style=self.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    self.editButton.title=self.editing ? @"Done" : @"Edit";
        
    //If in editing mode, enable all the text fields; otherwise, disable them
    for (UITextField *textField in self.textFields)
        textField.enabled=self.editing;
    
    //Enable or disable the text area
    self.fieldObservationTextArea.editable=self.editing;
    self.fieldObservationTextArea.backgroundColor=self.editing ? [UIColor whiteColor] : [UIColor clearColor];
    
    //enable or disable the take photo, browse photo, and acquire data buttons depending on whether or not edit has been pressed
    self.browseButton.enabled = self.editing;
    self.takePhotoButton.enabled = self.editing;
    self.acquireButton.enabled = self.editing;
}

- (void)styleFormInputFields {
    if (self.editing) {            
        //Make the background color of the textfields white
        for (UITextField *textField in self.textFields)
            textField.backgroundColor=[UIColor whiteColor];
        
        //Add border to the textfields
        for (UITextField *textField in self.textFields)
            textField.borderStyle=UITextBorderStyleRoundedRect;
        
    } else {
        //Make the background color of the textfields clear
        for (UITextField *textField in self.textFields)
            textField.backgroundColor=[UIColor clearColor];
        
        //Remove borders of the textfields
        for (UITextField *textField in self.textFields)
            textField.borderStyle=UITextBorderStyleNone;
    }
}

- (void)processFormInputsWithValidations {
    //Go through the validations
    NSDictionary *recordInfo=[self dictionaryFromForm];
    
    //If the info passes the validations, update the record
    if ([self validateMandatoryFieldsOfInfo:recordInfo alertsEnabled:YES])
        [self userDoneEditingRecord];
    else 
        [self setEditing:YES animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { 
    _editing=editing;
    
    //Toggle enable/disable dependending on whether self is in editing mode or not
    [self toggleEnableOfFormInputFields];
    
    //Style input fields accordingly to editing
    [self styleFormInputFields];
    
    //Stop updating location if still updating and self goes out of editing mode
    if (!self.editing && [self.gatheringGPS isAnimating])
        [self timerFired];
}

- (void)endEditingModeAndSaveWithValidationsEnabled:(BOOL)validationEnabled {
    //End editing mode
    [self setEditing:NO animated:YES];
    
    //Process form inputs
    if (validationEnabled)
        //Process the user input with validations
        [self processFormInputsWithValidations];
    else
        //Process without validations
        [self userDoneEditingRecord];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //If the alert view is a warning about fields being left blank
    if ([alertView.title isEqualToString:@"Missing Information"]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
            //End editing mode without going through the validations again
            [self endEditingModeAndSaveWithValidationsEnabled:NO];
        }
    }
}

#pragma mark - Keyboard Notification Handlers

- (void)registerForKeyboardNotifications {
    //Get the NSNotificationCenter and set self up to receive notifications when the keyboard slides in and slides out
    NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self 
                   selector:@selector(keyboardDidAppear:) 
                       name:UIKeyboardDidShowNotification 
                     object:nil];
    
    [notiCenter addObserver:self 
                   selector:@selector(keyboardWillHide:) 
                       name:UIKeyboardDidHideNotification 
                     object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    //If the UITextArea is currently the first responder (the keyboard caller), scroll it to visible
    if (self.fieldObservationTextArea.isFirstResponder) {
        //Get the info dictionary sent with the notification and get the size of the keyboard from it
        NSDictionary *notificationInfo=[notification userInfo];
        CGSize keyboardSize=[[notificationInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //Set the insets of the scroll view to fit the keyboard
        UIEdgeInsets contentInsets=UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        self.scrollView.contentInset=contentInsets;
        self.scrollView.scrollIndicatorInsets=contentInsets;
        CGRect aRect=self.view.frame;
        aRect.size.height-=keyboardSize.height;
        if (!CGRectContainsPoint(aRect, self.fieldObservationTextArea.frame.origin)) {
            CGPoint scrollPoint=CGPointMake(0.0,self.fieldObservationTextArea.frame.origin.y-self.fieldObservationLabel.frame.size.height);
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets=UIEdgeInsetsZero;
    self.scrollView.contentInset=contentInsets;
    self.scrollView.scrollIndicatorInsets=contentInsets;
}

#pragma mark - Target-Action Handlers for picker-using text fields

- (IBAction)textFieldDidBeginEdit:(UITextField *)sender {
    //Dismiss the keyboard
    [sender resignFirstResponder];
}

#pragma mark - Delegate methods for all Picker View Controller protocols

- (void)strikePickerViewController:(StrikePickerViewController *)sender 
          userDidSelectStrikeValue:(NSString *)strike
{
    //Set the strike text field's text
    self.strikeTextField.text=strike;
}

- (void)dipPickerViewController:(DipPickerViewController *)sender 
          userDidSelectDipValue:(NSString *)dip
{
    //Set the dip text field's text
    self.dipTextField.text=dip;
}

- (void)dipDirectionPickerViewController:(DipDirectionPickerViewController *)sender 
          userDidSelectDipDirectionValue:(NSString *)dipDirection
{
    //Set the dip direction text field's text
    self.dipDirectionTextField.text=dipDirection;
}

- (void)trendPickerViewController:(TrendPickerViewController *)sender 
          userDidSelectTrendValue:(NSString *)trend
{
    //Set the trend text field's text
    self.trendTextField.text=trend;
}

- (void)plungePickerViewController:(PlungePickerViewController *)sender 
          userDidSelectPlungeValue:(NSString *)plunge
{
    //Set the plunge text field's text
    self.plungeTextField.text=plunge;
}
- (void)formationPickerViewController:(FormationPickerViewController *)sender 
       userDidSelectFormationWithName:(NSString *)formationName
{
    //Set text fields based on whether the sender is the formation, lower formation, or upper formation textfield
    if ([sender.pickerName isEqualToString:FORMATION_PICKER_NAME]) {
        //Set the text of the formation text field
        self.formationTextField.text=formationName;
    }
    
    else if ([sender.pickerName isEqualToString:LOWER_FORMATION_PICKER_NAME]) {
        //Set the text of the formation text field
        self.lowerFormationTextField.text=formationName;
    }
    
    else if ([sender.pickerName isEqualToString:UPPER_FORMATION_PICKER_NAME]) {
        //Set the text of the formation text field
        self.upperFormationTextField.text=formationName;
    }
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Strike picker segue
    NSSet *pickerSegueIdentifiers=[NSSet setWithObjects:@"Strike Picker",@"Dip Picker",@"Dip Direction Picker",@"Plunge Picker",@"Trend Picker",@"Formation Picker",@"Lower Formation Picker",@"Upper Formation Picker", nil];
    if ([pickerSegueIdentifiers containsObject:segue.identifier]) {
        //Set self as the delegate of the popup Strike Picker
        [segue.destinationViewController setDelegate:self];
    }
    
    //Controls whether the PickerVC popovers would pass initial values back when they appear
    if ([segue.identifier isEqualToString:@"Strike Picker"]) {
        //Will send initial value to strike picker text field only if its value is currently 0
        [segue.destinationViewController setInitialSelectionEnabled:[self.strikeTextField.text isEqualToString:@"0"]];
        [segue.destinationViewController setPreviousSelection:self.strikeTextField.text];
    } else if ([segue.identifier isEqualToString:@"Dip Picker"]) {
        //Will send initial value to dip text field only if its value is currently 0
        [segue.destinationViewController setInitialSelectionEnabled:[self.dipTextField.text isEqualToString:@"0"]];
        [segue.destinationViewController setPreviousSelection:self.dipTextField.text];
    } else if ([segue.identifier isEqualToString:@"Dip Direction Picker"]) {
        //Will send initial value to dip direction text field only if it's currently blank (no direction selected)
        [segue.destinationViewController setInitialSelectionEnabled:![self.dipDirectionTextField.text length]];
        [segue.destinationViewController setPreviousSelection:self.dipDirectionTextField.text];
    } else if ([segue.identifier isEqualToString:@"Trend Picker"]) {
        //Will send initial value to trend text field only if it's currently blank (no value selected)
        [segue.destinationViewController setInitialSelectionEnabled:![self.trendTextField.text length]];\
        [segue.destinationViewController setPreviousSelection:self.trendTextField.text];
    } else if ([segue.identifier isEqualToString:@"Plunge Picker"]) {
        //Will send initial value to plunge picker text field only if it's currently blank
        [segue.destinationViewController setInitialSelectionEnabled:![self.plungeTextField.text length]];
        [segue.destinationViewController setPreviousSelection:self.plungeTextField.text];
    }
    
    //Seguing to the formation picker view controller for the formation text field
    else if ([segue.identifier isEqualToString:@"Formation Picker"]) {
        //Set the database of the formation picker
        [segue.destinationViewController setDatabase:[self.delegate databaseForFormationPicker]];
        
        //Set initialSelection for the formation picker if the current record has no formation set yet
        [segue.destinationViewController setInitialSelectionEnabled:![self.formationTextField.text length]];
        
        //Set the name of the picker
        [segue.destinationViewController setPickerName:FORMATION_PICKER_NAME];
        
        //Set the name of the formation folder
        [segue.destinationViewController setFolderName:[self.delegate formationFolderName]];
        
        //Set the previously selected formation name
        [segue.destinationViewController setPreviousSelection:self.formationTextField.text];
    }
    
    //Seguing to the formation picker view controller for the lower formation text field
    else if ([segue.identifier isEqualToString:@"Lower Formation Picker"]) {
        //Set the database of the lower formation picker
        [segue.destinationViewController setDatabase:[self.delegate databaseForFormationPicker]];
        
        //Set initialSelection for the formation picker if the current record has no lower formation set yet
        [segue.destinationViewController setInitialSelectionEnabled:![self.lowerFormationTextField.text length]];
        
        //Set the name of the picker
        [segue.destinationViewController setPickerName:LOWER_FORMATION_PICKER_NAME];
        
        //Set the name of the formation folder
        [segue.destinationViewController setFolderName:[self.delegate formationFolderName]];
        
        //Set the previously selected formation name
        [segue.destinationViewController setPreviousSelection:self.lowerFormationTextField.text];
    }
    
    //Seguing to the formation picker view controller for the upper formation text field
    else if ([segue.identifier isEqualToString:@"Upper Formation Picker"]) {
        //Set the database of the formation picker
        [segue.destinationViewController setDatabase:[self.delegate databaseForFormationPicker]];
        
        //Set initialSelection for the formation picker if the current record has no upper formation set yet
        [segue.destinationViewController setInitialSelectionEnabled:![self.upperFormationTextField.text length]];
        
        //Set the name of the picker
        [segue.destinationViewController setPickerName:UPPER_FORMATION_PICKER_NAME];
        
        //Set the name of the formation folder
        [segue.destinationViewController setFolderName:[self.delegate formationFolderName]];
        
        //Set the previously selected formation name
        [segue.destinationViewController setPreviousSelection:self.upperFormationTextField.text];
    }
    
    //Seguing to the modal formation folder tvc
    else if ([segue.identifier isEqualToString:@"Show Formation Folders"]) {
        //Get the destination view controller
        UINavigationController *navigationController=segue.destinationViewController;
        FormationFolderTableViewController *destinationViewController=(FormationFolderTableViewController *)navigationController.topViewController;
        
        //Dismiss the old popover if its still visible
        if (self.formationFolderPopoverController.isPopoverVisible)
            [self.formationFolderPopoverController dismissPopoverAnimated:NO];
        
        //Dismiss the master popover if it's visible on the screen
        if (self.masterPopoverController.isPopoverVisible) {
            [self.masterPopoverController dismissPopoverAnimated:NO];
        }
        
        //Save the popover
        self.formationFolderPopoverController=[(UIStoryboardPopoverSegue *)segue popoverController];
        
        //Get the shared database
        UIManagedDocument *database=[GeoDatabaseManager standardDatabaseManager].geoFieldBookDatabase;
        
        //Open the database if it's still closed
        if (database.documentState==UIDocumentStateClosed) {
            [database openWithCompletionHandler:^(BOOL success){
                destinationViewController.database=database;
            }];
        } else if (database.documentState==UIDocumentStateNormal) {
            destinationViewController.database=database;
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Update the form
    [self updateFormForRecord:self.record];
    
    //Set self up to receive notifications when the keyboard appears and disappears (to adjust the text fields and areas when keyboard shows up)
    [self registerForKeyboardNotifications];
    
    //initialize and set up location services
    [self setUpLocationManager];
    
    //Add double tap recognizer (a double tap outside the text fields or text areas will dismiss the keyboard)
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
} 

- (void)viewWillLayoutSubviews {
    //If the image picker popover is still on screen, adjust its frame
    if (self.imagePopover.isPopoverVisible) {
        if (self.imagePickerPresenter!=self.browseButton) {
            //Get the content view controlelr (an image picker)
            UIImagePickerController *imagePicker=(UIImagePickerController *)self.imagePopover.contentViewController;
        
            //Resize the popover when in portrait mode
            if ([UIApplication sharedApplication].statusBarOrientation==UIInterfaceOrientationPortrait) {
                [self.imagePopover setPopoverContentSize:CGSizeMake(imagePicker.view.frame.size.height, imagePicker.view.frame.size.width)];
            }
        }
        
        //Reposition the popover
        [self.imagePopover presentPopoverFromRect:self.imagePickerPresenter.bounds inView:self.imagePickerPresenter permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setRecordTypeLabel:nil];
    [self setRecordNameTextField:nil];
    [self setDipTextField:nil];
    [self setFormationTextField:nil];
    [self setDipDirectionTextField:nil];
    [self setFieldObservationTextArea:nil];
    [self setFormationLabel:nil];
    [self setStrikeLabel:nil];
    [self setDipLabel:nil];
    [self setDipDirectionLabel:nil];
    [self setScrollView:nil];
    [self setTrendLabel:nil];
    [self setTrendTextField:nil];
    [self setPlungeLabel:nil];
    [self setPlungeTextField:nil];
    [self setLowerFormationLabel:nil];
    [self setLowerFormationTextField:nil];
    [self setUpperFormationLabel:nil];
    [self setUpperFormationTextField:nil];
    [self setFieldObservationLabel:nil];
    [self setAcquireButton:nil];
    [self setEditButton:nil];
    [self setLatitudeTextField:nil];
    [self setLongitudeTextField:nil];
    [self setDateTextField:nil];
    [self setTimeTextField:nil];
    [self setMasterPresenter:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Set up the record form for each individual type of record

- (void)populateFormWithInfoOfRecord:(Record *)record {
    //Fill in the information from the record
    self.recordNameTextField.text=self.record.name;
    self.latitudeTextField.text=self.record.latitude;
    self.longitudeTextField.text=self.record.longitude;
    
    //set the image
    self.imageView.image=[UIImage imageWithData:self.record.image.imageData];
    
    //Set the date and time
    self.dateTextField.text = [Record dateFromNSDate:record.date];
    self.timeTextField.text = [Record timeFromNSDate:record.date];
    self.acquiredDate=self.record.date;
    
    //Set the strike and dip
    self.strikeTextField.text=[NSString stringWithFormat:@"%@",self.record.strike];
    self.dipTextField.text=[NSString stringWithFormat:@"%@",self.record.dip];
    
    //Set the dip direction and field observation
    self.dipDirectionTextField.text=self.record.dipDirection;
    self.fieldObservationTextArea.text=self.record.fieldOservations;
    
    //Set the record type
    self.recordTypeLabel.text=[self.record.class description];
}

- (void)updateFormForRecord:(Record *)record {
    //Clear the color of the field observation text area
    self.fieldObservationTextArea.backgroundColor=[UIColor clearColor];
    
    //Hide the formation, trend, plunge. lower, upper formations textfields and will put them up again if the record type requires them (WHITELISTING)
    NSSet *hiddenFields=[NSSet setWithObjects:self.trendTextField,self.trendLabel,self.plungeLabel,self.plungeTextField,self.formationLabel,self.formationTextField,self.lowerFormationLabel,self.lowerFormationTextField,self.upperFormationLabel,self.upperFormationTextField, nil];
    [hiddenFields makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
    
    //populate the common information shared by all types of records
    [self populateFormWithInfoOfRecord:record];
    
    //Setup the textfields and labels depending on the type of record
    if ([record isKindOfClass:[Bedding class]]) {
        [self formSetupForBeddingType];
    } else if ([record isKindOfClass:[Contact class]]) {
        [self formSetupForContactType];
    } else if ([record isKindOfClass:[Fault class]]) {
        [self formSetupForFaultType];
    } else if ([record isKindOfClass:[JointSet class]]) {
        [self formSetupForJointSetType];
    } else if ([record isKindOfClass:[Other class]]) {
        [self formSetupForOtherType];
    }    
}

- (void)formSetupForBeddingType {
    Bedding *bedding=(Bedding *)self.record;
    
    //Show the formation label and formation textfield set the textfield's value
    self.formationLabel.hidden=NO;
    self.formationTextField.hidden=NO;
    self.formationTextField.text=bedding.formation ? bedding.formation.formationName : @"";
}

- (void)formSetupForContactType {
    //Show the plunge and trend text labels and text fields
    NSSet *showedFields=[NSSet setWithObjects:self.lowerFormationTextField,self.lowerFormationLabel,self.upperFormationTextField,self.upperFormationLabel, nil];
    [showedFields makeObjectsPerformSelector:@selector(setHidden:) withObject:nil];
    
    //Setup the two lower and upper formation fields
    Contact *contact=(Contact *)self.record;
    self.lowerFormationTextField.text=contact.lowerFormation ? contact.lowerFormation.formationName : @"";
    self.upperFormationTextField.text=contact.upperFormation ? contact.upperFormation.formationName : @"";
}

- (void)formSetupForJointSetType {
    //Show the formation label and text field
    self.formationTextField.hidden=NO;
    self.formationLabel.hidden=NO;
    
    //Set the formation text field
    JointSet *jointSet=(JointSet *)self.record;
    self.formationTextField.text=jointSet.formation ? jointSet.formation.formationName : @"";
}

- (void)formSetupForFaultType {
    Fault *fault=(Fault *)self.record;
    
    //Show the trend, plunge and formation labels and text fields
    NSSet *showedFields=[NSSet setWithObjects:self.plungeLabel,self.plungeTextField,self.trendLabel,self.trendTextField,self.formationLabel,self.formationTextField, nil];
    for (UITextField *textField in showedFields)
        textField.hidden=NO;
    
    //Set the trend and plunge text fields
    self.plungeTextField.text=fault.plunge ? fault.plunge : @"";
    self.trendTextField.text=fault.trend ? fault.trend : @"";
    
    //Set the formation text field
    self.formationTextField.text=fault.formation ? fault.formation.formationName : @"";    
}

- (void)formSetupForOtherType {
    //Hide all the textfields except for the name textfield
    [self.textFields makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
    self.recordNameTextField.hidden=NO;
    
    //Hide the strike, dip, and dip direction, field observation labels
    NSSet *hiddenFields=[NSSet setWithObjects:self.strikeLabel,self.dipLabel,self.dipDirectionLabel,self.formationLabel, nil];
    for (UITextField *textField in hiddenFields)
        textField.hidden=YES;
}

@end