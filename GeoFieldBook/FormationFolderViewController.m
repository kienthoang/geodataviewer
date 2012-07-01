//
//  FormationFolderViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/25/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationFolderViewController.h"

@interface FormationFolderViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation FormationFolderViewController

@synthesize nameTextField=_nameTextField;
@synthesize folderName=_folderName;

@synthesize delegate=_delegate;

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    //If the formation folder name text field is blank, focus on it isntead of returning
    if (![self.nameTextField.text length])
        [self.nameTextField becomeFirstResponder];
    
    //Else pass the name back to the delegate
    else {
        //If the folder name has not been set before, send the delegate the new name
        if (!self.folderName)
            [self.delegate formationFolderViewController:self 
                         didObtainNewFormationFolderName:self.nameTextField.text];
        
        //Else send both the origin name and the new name
        else 
            [self.delegate formationFolderViewController:self 
                            didAskToModifyFolderWithName:self.folderName 
                                      andObtainedNewName:self.nameTextField.text];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //If the text field is the name text field
    if (textField==self.nameTextField) {
        //If the text field's text is not empty, click done for the user and return YES
        [self donePressed:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Gesture Handlers

//Workaround to dismiss the keyboard when double clicking out because the keyboard is kinda messed up in a modal view controller
- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //Dismiss the keyboard
    [self.nameTextField resignFirstResponder];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Add double tap gesture recognizer for dismissing the keyboard
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Set the name text field to be the first responder
    [self.nameTextField becomeFirstResponder];
    
    //Set the delegate of the name text field to be self
    self.nameTextField.delegate=self;
    self.nameTextField.returnKeyType=UIReturnKeyDone;
    self.nameTextField.enablesReturnKeyAutomatically=YES;
    
    //If the folder name is not nil, set the text of the name text field
    if (self.folderName)
        self.nameTextField.text=self.folderName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidUnload {
    [self setNameTextField:nil];
    [super viewDidUnload];
}
@end
