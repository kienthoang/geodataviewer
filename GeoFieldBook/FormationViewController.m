//
//  FormationViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "FormationViewController.h"

@interface FormationViewController() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation FormationViewController
@synthesize nameTextField = _nameTextField;

@synthesize delegate=_delegate;
@synthesize formationName=_formationName;

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //dismiss the keyboard
    [self.nameTextField resignFirstResponder];
}

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    //If the formation name text field is blank, focus on it isntead of returning
    if (![self.nameTextField.text length])
        [self.nameTextField becomeFirstResponder];
    
    //Else pass the name back to the delegate
    else {
        //If the folder name has not been set before, send the delegate the new name
        if (!self.formationName)
            [self.delegate formationViewController:self 
                         didObtainNewFormationName:self.nameTextField.text];
        
        //Else send both the origin name and the new name
        else 
            [self.delegate formationViewController:self 
                   didAskToModifyFormationWithName:self.formationName 
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

#pragma mark - View Controller Lifecycles

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Add double tap gesture recognizer for dismissing the keyboard
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    //Set the delegate of the name text field to be self
    self.nameTextField.delegate=self;
    self.nameTextField.returnKeyType=UIReturnKeyDone;
    self.nameTextField.enablesReturnKeyAutomatically=YES;
    
    //Set the name text field to be the first responder
    [self.nameTextField becomeFirstResponder];
    
    //If the formation name is not nil, set the text of the name text field
    if (self.formationName)
        self.nameTextField.text=self.formationName;
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
