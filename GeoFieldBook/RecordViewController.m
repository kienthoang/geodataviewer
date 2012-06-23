//
//  RecordViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordViewController.h"
#import "Record+Modification.h"
#import "TextInputFilter.h"
#import "Record.h"
#import "Formation.h"
#import "Bedding.h"
#import "Contact.h"
#import "JointSet.h"
#import "JointSet+Description.h"
#import "Fault.h"
#import "Other.h"

@interface RecordViewController() <UINavigationControllerDelegate>

@property (weak,nonatomic) IBOutlet UIToolbar *toolbar;

- (void)updateSplitViewBarButtonPresenterWith:(UIBarButtonItem *)splitViewBarButtonItem;
- (void)userDoneEditingRecord;         //handles when user finishes editing the record's info

@property (nonatomic) BOOL editing;
@property (nonatomic,readonly) NSArray *textFields;

//=====================================UI elements=======================================//

@property (weak, nonatomic) IBOutlet UIImageView *recordImage;
@property (weak, nonatomic) IBOutlet UILabel *recordTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *recordNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *recordLatitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLongitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *strikeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipTextField;
@property (weak, nonatomic) IBOutlet UITextField *formationTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipDirectionTextField;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UILabel *field2Label;
@property (weak, nonatomic) IBOutlet UILabel *field1Label;
@property (weak, nonatomic) IBOutlet UITextView *fieldObservationTextArea;
@property (weak, nonatomic) IBOutlet UILabel *formationLabel;
@property (weak, nonatomic) IBOutlet UILabel *strikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipDirectionLabel;

//=========================================================================================//

//==================================Form Setup methods for UI elements=======================================//

- (void)formSetupForBeddingType;
- (void)formSetupForContactType;
- (void)formSetupForJointSetType;
- (void)formSetupForFaultType;
- (void)formSetupForOtherType;

- (void)updateFormForRecord:(Record *)record;

//===========================================================================================================//

@end

@implementation RecordViewController

@synthesize record=_record;

@synthesize recordImage = _recordImage;
@synthesize recordTypeLabel = _recordTypeLabel;
@synthesize recordNameTextField = _recordNameTextField;
@synthesize recordLatitudeLabel = _recordLatitudeLabel;
@synthesize recordLongitudeLabel = _recordLongitudeLabel;
@synthesize recordDateLabel = _recordDateLabel;
@synthesize recordTimeLabel = _recordTimeLabel;
@synthesize strikeTextField = _strikeTextField;
@synthesize dipTextField = _dipTextField;
@synthesize dipDirectionTextField = _dipDirectionTextField;
@synthesize dipLabel = _dipLabel;
@synthesize formationTextField = _formationTextField;
@synthesize dipDirectionLabel = _dipDirectionLabel;
@synthesize textField2 = _textField2;
@synthesize textField1 = _textField1;
@synthesize field2Label = _field2Label;
@synthesize field1Label = _field1Label;
@synthesize fieldObservationTextArea = _fieldObservationTextArea;
@synthesize formationLabel = _formationLabel;
@synthesize strikeLabel = _strikeLabel;

@synthesize editing=_editing;

@synthesize toolbar=_toolbar;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;

@synthesize delegate=_delegate;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    //Update the bar button presenter
    [self updateSplitViewBarButtonPresenterWith:splitViewBarButtonItem];
    
    _splitViewBarButtonItem=splitViewBarButtonItem;
}

- (void)setRecord:(Record *)record {
    _record=record;
    
    //Update the text fields and labels
    [self updateFormForRecord:self.record];
}

- (void)updateSplitViewBarButtonPresenterWith:(UIBarButtonItem *)splitViewBarButtonItem {
    //Add the button to the toolbar
    NSMutableArray *items=[self.toolbar.items mutableCopy];
    
    //Remove the old button if it exists
    if (self.splitViewBarButtonItem)
        [items removeObject:self.splitViewBarButtonItem];
        
    //Add the new button on the leftmost if it's not nil
    if (splitViewBarButtonItem)
        [items insertObject:splitViewBarButtonItem atIndex:0];
    
    //Set the items to be the toolbar's items
    self.toolbar.items=[items copy];
}

- (NSArray *)textFields {
    return [NSArray arrayWithObjects:self.recordNameTextField,self.strikeTextField,self.dipTextField,self.dipDirectionTextField,self.formationTextField,self.textField1,self.textField2, nil];
}

//Creates and returns the user-modified info dictionary
- (NSDictionary *)dictionaryFromForm {
    //Create a NSDictionary with the user-modified information
    NSMutableDictionary *recordDictionary=[NSMutableDictionary dictionary];
    [recordDictionary setObject:self.recordNameTextField.text forKey:RECORD_NAME];
    //[recordDictionary setObject:self.recordLatitudeLabel.text forKey:RECORD_LATITUDE];
    //[recordDictionary setObject:self.recordLongitudeLabel.text forKey:RECORD_LONGITUDE];
    //[recordDictionary setObject:self.recordDateLabel.text forKey:RECORD_DATE];
    //[recordDictionary setObject:self.recordTimeLabel.text forKey:RECORD_TIME];
    [recordDictionary setObject:self.strikeTextField.text forKey:RECORD_STRIKE];
    [recordDictionary setObject:self.dipTextField.text forKey:RECORD_DIP];
    [recordDictionary setObject:self.dipDirectionTextField.text forKey:RECORD_DIP_DIRECTION];
    [recordDictionary setObject:self.formationTextField.text forKey:RECORD_FORMATION];
    [recordDictionary setObject:self.fieldObservationTextArea.text forKey:RECORD_FIELD_OBSERVATION];
    
    //Specific update for specific of records
    if ([self.record isKindOfClass:[Fault class]]) {
        [recordDictionary setObject:self.textField1.text forKey:RECORD_PLUNGE];
        [recordDictionary setObject:self.textField2.text forKey:RECORD_TREND];
    } else if ([self.record isKindOfClass:[Contact class]]) {
        [recordDictionary setObject:self.textField1.text forKey:RECORD_LOWER_FORMATION];
        [recordDictionary setObject:self.textField2.text forKey:RECORD_UPPER_FORMATION];
    }
    
    return [recordDictionary copy];
}

- (void)userDoneEditingRecord {
    //Pass the user-modified info dictionary to the delegate for processing
    [self.delegate recordViewController:self userDidModifyRecord:self.record withNewRecordInfo:[self dictionaryFromForm]];
}

#pragma mark - Gesture Handlers

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //dismiss the keyboard
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
    [self.fieldObservationTextArea resignFirstResponder];
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle the editting mode
    [self setEditing:!self.editing animated:YES];
    
    //Change the style of the button to edit or done
    sender.style=self.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.editing ? @"Done" : @"Edit";
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:YES];
    
    //If the record name is empty, focus on its text field and the user wants the editing mode
    self.recordNameTextField.text=[TextInputFilter filterDatabaseInputText:self.recordNameTextField.text];
    if (![self.recordNameTextField.text length] && !editing) 
        [self.recordNameTextField becomeFirstResponder];
    
    //Else proceed as normal
    else {
        _editing=editing;
        
        //If in editing mode, enable all the text fields; otherwise, disable them (YES is 1, NO is 0)
        for (UITextField *textField in self.textFields)
            textField.enabled=self.editing;
        
        //Enable or disable the text area
        self.fieldObservationTextArea.editable=editing;
        self.fieldObservationTextArea.backgroundColor=self.editing ? [UIColor whiteColor] : [UIColor clearColor];
        
        if (editing) {
            //Make the background color of the textfields white
            [self.textFields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor whiteColor]];
            
            //Add border to the textfields
            for (UITextField *textField in self.textFields)
                textField.borderStyle=UITextBorderStyleRoundedRect;
            
        } else {
            //Make the background color of the textfields clear
            [self.textFields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor]];
            
            //Remove borders of the textfields
            for (UITextField *textField in self.textFields)
                textField.borderStyle=UITextBorderStyleNone;
            
            //Proceed to editing the record with the user-modified info
            [self userDoneEditingRecord];
        }
    }
}

- (IBAction)acquireData:(UIBarButtonItem *)sender {
}

- (IBAction)browsePressed:(UIBarButtonItem *)sender {
}

- (IBAction)takePhoto:(UIBarButtonItem *)sender {
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)newMaster animated:(BOOL)animated {
    //Change the splitview button's title if it exists
    if (self.splitViewBarButtonItem)
        self.splitViewBarButtonItem.title=newMaster.navigationItem.title;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    //Update the form
    [self updateFormForRecord:self.record];
}

- (void)viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];
    
    //Set self to be the master's navigation controller's delegate to change the button's title when a push segue in master happens
    UINavigationController *masterNavigation=[self.splitViewController.viewControllers objectAtIndex:0];
    masterNavigation.delegate=self;
    
    //Update the bar button presenter if self.splitViewBarButtonItem exists (transferred from somewhere else when this vc got segued to)
    [self updateSplitViewBarButtonPresenterWith:self.splitViewBarButtonItem];
    
    //Add double tap recognizer (a double tap outside the text fields or text areas will dismiss the keyboard)
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //If self is still in editing mode, notify the delegate before going off screen
    if (self.editing && [self.delegate respondsToSelector:@selector(userDidNavigateAwayFrom:whileModifyingRecord:withNewRecordInfo:)]) {
        //If the delegate has not been deallocated yet, pass the user-modified info to it
        if (self.delegate)
            [self.delegate userDidNavigateAwayFrom:self whileModifyingRecord:self.record withNewRecordInfo:[self dictionaryFromForm]];
    }
}

- (void)viewDidUnload {
    [self setRecordImage:nil];
    [self setRecordTypeLabel:nil];
    [self setRecordNameTextField:nil];
    [self setRecordLatitudeLabel:nil];
    [self setRecordLongitudeLabel:nil];
    [self setRecordDateLabel:nil];
    [self setRecordTimeLabel:nil];
    [self setStrikeTextField:nil];
    [self setDipTextField:nil];
    [self setFormationTextField:nil];
    [self setDipDirectionTextField:nil];
    [self setTextField2:nil];
    [self setTextField1:nil];
    [self setFieldObservationTextArea:nil];
    [self setField2Label:nil];
    [self setField1Label:nil];
    [self setFormationLabel:nil];
    [self setStrikeLabel:nil];
    [self setDipLabel:nil];
    [self setDipDirectionLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Set up the record form for each individual type of record

- (void)updateFormForRecord:(Record *)record {
    //Reset all the textfields to empty strings
    [self.textFields makeObjectsPerformSelector:@selector(setText:) withObject:@""];
    
    //Clear the color of the field observation text area
    self.fieldObservationTextArea.backgroundColor=[UIColor clearColor];
    
    //Fill in the information from the record
    self.recordNameTextField.text=self.record.name ? self.record.name : @"";
    self.recordLatitudeLabel.text=self.record.latitude;
    self.recordLongitudeLabel.text=self.record.longitude;
    self.strikeTextField.text=self.record.strike ? [NSString stringWithFormat:@"%@",self.record.strike] : @"";
    self.dipTextField.text=self.record.dip ? [NSString stringWithFormat:@"%@",self.record.dip] : @"";
    self.dipDirectionTextField.text=self.record.dipDirection ? self.record.dipDirection : @"";
    self.fieldObservationTextArea.text=self.record.fieldOservations ? self.record.fieldOservations : @"";
    self.recordTypeLabel.text=[self.record.class description];
    
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
    
    //Hide the two text fields
    self.textField1.hidden=YES;
    self.field1Label.hidden=YES;
    self.textField2.hidden=YES;
    self.field2Label.hidden=YES;
    self.formationTextField.text=bedding.formation ? bedding.formation.formationName : @"";
}

- (void)formSetupForContactType {
    //Setup the two text fields
    Contact *contact=(Contact *)self.record;
    self.field1Label.text=@"Lower Formation:";
    self.field2Label.text=@"Upper Formation:";
    self.textField1.text=contact.lowerFormation ? contact.lowerFormation.formationName : @"";
    self.textField2.text=contact.upperFormation ? contact.upperFormation.formationName : @"";
    
    //Hide the formation label and text field
    self.formationTextField.hidden=YES;
    self.formationLabel.hidden=YES;
}

- (void)formSetupForJointSetType {
    //Set the formation text field
    JointSet *jointSet=(JointSet *)self.record;
    self.formationTextField.text=jointSet.formation ? jointSet.formation.formationName : @"";
    
    //Hide the text fields 1 and 2
    self.textField1.hidden=YES;
    self.textField2.hidden=YES;
    self.field1Label.hidden=YES;
    self.field2Label.hidden=YES;
}

- (void)formSetupForFaultType {
    Fault *fault=(Fault *)self.record;
    
    //Set the two text fields 1 and 2
    self.field1Label.text=@"Plunge:";
    self.field2Label.text=@"Trend:";
    self.textField1.text=fault.plunge ? fault.plunge : @"";
    self.textField2.text=fault.trend ? fault.trend : @"";
    
    //Set the formation
    self.formationTextField.text=fault.formation ? fault.formation.formationName : @"";
}

- (void)formSetupForOtherType {
    //Hide all the textfields except for the name textfield
    [self.textFields makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:NO]];
    self.recordNameTextField.hidden=NO;
    
    //Hide all the labels corresponding to the hidden textfields
    self.strikeLabel.hidden=YES;
    self.dipLabel.hidden=YES;
    self.dipDirectionLabel.hidden=YES;
    self.formationLabel.hidden=YES;
    self.field1Label.hidden=YES;
    self.field2Label.hidden=YES;
}

@end