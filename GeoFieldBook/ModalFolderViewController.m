//
//  ModalFolderViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ModalFolderViewController.h"

@interface ModalFolderViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *folderNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *folderDescriptionTextArea;

@end

@implementation ModalFolderViewController
@synthesize folderNameTextField = _folderNameTextField;
@synthesize folderDescriptionTextArea = _folderDescriptionTextArea;

@synthesize delegate=_delegate;
@synthesize folder=_folder;

#pragma mark - Getters and Setters

- (void)setFolderName:(Folder *)folder {
    if (_folder!=folder) {
        _folder=folder;
        
        //Set up the text fields and areas
        self.folderNameTextField.text=self.folder.folderName;
        self.folderDescriptionTextArea.text=self.folder.folderDescription;        
    }
}

- (void)setFolderNameTextField:(UITextField *)folderNameTextField {
    _folderNameTextField=folderNameTextField;
    
    //Set the folder name text field's delegate to be self
    self.folderNameTextField.delegate=self;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //If the text field is the name text field
    if (textField==self.folderNameTextField) {
        //If the text field is blank, don't end editing
        if (![textField.text length])
            return NO;
        
        //Else return YES, make the text field resign as first responder and then focus on the description text view
        else {
            [textField resignFirstResponder];
            [self.folderDescriptionTextArea becomeFirstResponder];
            return YES;
        }
    }
        
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the text field's text to the folder name and the description area's text to the folder's description if the folder is not nil
    if (self.folder) {
        self.folderNameTextField.text=self.folder.folderName;
        self.folderDescriptionTextArea.text=self.folder.folderDescription;
    }
    
    //Set the folder text field's area to be self
    self.folderNameTextField.delegate=self;
    
    //Set the title of self: if folderName is set, the user is editting an existing folder; otherwise, he/she is creating a new folder
    self.navigationItem.title=self.folder ? @"Edit Folder" : @"New Folder";
    
    //Style the keyboard for the folder name text field
    self.folderNameTextField.returnKeyType=UIReturnKeyNext;
    self.folderNameTextField.enablesReturnKeyAutomatically=YES;
    
    //Add tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Focus on the folder name text field
    [self.folderNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setFolderNameTextField:nil];
    [self setFolderDescriptionTextArea:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Form Information Collectors

//Create a dictionary of info of the new/modified folder
- (NSDictionary *)dictionaryFromFolderForm {
    NSMutableDictionary *folderInfo=[NSMutableDictionary dictionary];
    [folderInfo setObject:self.folderNameTextField.text forKey:FOLDER_NAME];
    [folderInfo setObject:self.folderDescriptionTextArea.text forKey:FOLDER_DESCRIPTION];
        
    return folderInfo;
}

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)confirmPressed:(UIBarButtonItem *)sender {
    //if the folder name text field is blank, focus on it
    NSString *folderName=[self.folderNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![folderName length])
        [self.folderNameTextField becomeFirstResponder];
    
    //Else call the delegate and pass on the name of the folder
    else {
        //If the folder has not been set before
        if (!self.folder)
            [self.delegate modalFolderViewController:self 
                               obtainedNewFolderInfo:[self dictionaryFromFolderForm]];
        else 
            [self.delegate modalFolderViewController:self 
                                didAskToModifyFolder:self.folder 
                          obtainedModifiedFolderInfo:[self dictionaryFromFolderForm]];
    }
}

#pragma mark - Gesture Handlers

//Workaround to dismiss the keyboard when double clicking out because the keyboard is kinda messed up in a modal view controller
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)hideKeyBoard:(UITapGestureRecognizer *)tapGesture {
    //Dismiss keyboard
    [self.folderNameTextField resignFirstResponder];
    [self.folderDescriptionTextArea resignFirstResponder];
}

@end
