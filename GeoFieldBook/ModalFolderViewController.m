//
//  ModalFolderViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ModalFolderViewController.h"

@interface ModalFolderViewController()

@property (weak, nonatomic) IBOutlet UITextField *folderNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *folderDescriptionTextArea;

@end

@implementation ModalFolderViewController
@synthesize folderNameTextField = _folderNameTextField;
@synthesize folderDescriptionTextArea = _folderDescriptionTextArea;

@synthesize delegate=_delegate;
@synthesize folder=_folder;

- (void)setFolderName:(Folder *)folder {
    if (_folder!=folder) {
        _folder=folder;
        
        //Set up the text fields and areas
        self.folderNameTextField.text=self.folder.folderName;
        self.folderDescriptionTextArea.text=self.folder.folderDescription;
        
        NSLog(@"Set the description: %@",self.folderDescriptionTextArea.text);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the text field's text to the folder name and the description area's text to the folder's description if the folder is not nil
    if (self.folder) {
        self.folderNameTextField.text=self.folder.folderName;
        self.folderDescriptionTextArea.text=self.folder.folderDescription;
    }
    
    //Set the title of self: if folderName is set, the user is editting an existing folder; otherwise, he/she is creating a new folder
    self.navigationItem.title=self.folder ? @"Edit Folder" : @"New Folder";
    
    //Add tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Focus on the folder name text field
    [self.folderNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setFolderNameTextField:nil];
    [self setFolderDescriptionTextArea:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view. (generated automatically by xcode)
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

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
