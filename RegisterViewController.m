//
//  RegisterViewController.m
//  SanJoseLibrary
//
//  Created by Himanshu Tantia on 5/8/14.
//  Copyright (c) 2014 Himanshu Tantia. All rights reserved.
//

#import "RegisterViewController.h"
#import "SelectMemberViewController.h"
#import "ServiceRequest.h"
#import "Branches.h"
#import "Branch.h"
#import "Account.h"
#import "Utillities.h"
#import "UIColor+SJPLColors.h"

@interface RegisterViewController () <UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberText;
@property (weak, nonatomic) IBOutlet UITextField *passcodeTxt;
@property (weak, nonatomic) IBOutlet UITextField *emailsTxt;
@property (weak, nonatomic) IBOutlet UIPickerView *branchNamesPicker;

@property (weak, nonatomic) IBOutlet UITableViewCell *accountNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *passcodeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *pickerCell;

@property (strong, nonatomic) NSArray *tableViewCells;
@property (strong, nonatomic) Branches *branches;

@property (assign, nonatomic) BOOL isRegistrationModeActive;
@property (assign, nonatomic) BOOL canSubmitRequest;

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableViewCells = @[self.accountNameCell,
                            self.passcodeCell,
                            self.phoneNumberCell,
                            self.emailCell,
                            self.pickerCell];
    self.isRegistrationModeActive = NO;
    
    [self.accountNameTxt becomeFirstResponder];
    
    self.view.backgroundColor = [UIColor colorWithBackgroundImage];
    
    ServiceRequest *sr = [ServiceRequest sharedRequest];
    [sr getBranchDetailsWithCompletionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
        self.branches = [[Branches alloc] branchesWithProperties:(NSArray *)json];
        
        if (response) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.branchNamesPicker reloadAllComponents];
            });
        }
        else
            [self.branchNamesPicker reloadAllComponents];
        
    }];
}

-(void)startRegistrationRequest
{
    ServiceRequest *sr = [ServiceRequest sharedRequest];
    Account *acc = [Account new];
    acc.accountName = self.accountNameTxt.text;
    acc.phone = self.phoneNumberText.text;
    acc.passcode = self.passcodeTxt.text;
    acc.emailAddress = self.emailsTxt.text;
    
    NSUInteger selection = [self.branchNamesPicker selectedRowInComponent:0];
    acc.branchId = ((Branch *)[self.branches.branches objectAtIndex:selection]).id;
    
    [sr startRegisterTaskWithParameters:acc completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
        
        if (response) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (json) {
                    [self handleRegistrationCompleteWithData:json];
                } else {
                    [self handleRegistrationFailedWithError:error];
                }
            });
        }
        else
        {
            if (json) {
                [self handleRegistrationCompleteWithData:json];
            } else {
                [self handleRegistrationFailedWithError:error];
            }
        }
        
    }];
}

-(void)startLoginRequest
{
    Account *acc = [Account new];
    acc.accountName = self.accountNameTxt.text;
    acc.passcode = self.passcodeTxt.text;
    ServiceRequest *sr = [ServiceRequest sharedRequest];
    [sr startLoginTaskWithParameters:acc
                   completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
                       Account *acc = [Account AccountWithProperties:json];
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           [self handleResponse:acc];
                       });
                   }];
}

-(void)handleResponse:(Account *)accountInfo
{
    if ([accountInfo.id length]) {
        [self.presentingController setAccountInfo:accountInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [self.presentingController didDismissLoginViewController];
        }];
    }
    else
    {
        UIAlertView *error = [Utillities alertViewWithTitle:@"Signin Error" message:@"Failed to login with the supplied credentials" delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Ok",nil];
        [error show];
        [self.accountNameTxt becomeFirstResponder];
    }
}

- (IBAction)registerAction:(UIBarButtonItem *)sender
{
    if (!self.branches.branches && [self.branches.branches count]==0) {
        ServiceRequest *sr = [ServiceRequest sharedRequest];
        [sr getBranchDetailsWithCompletionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error) {
            self.branches = [[Branches alloc] branchesWithProperties:(NSArray *)json];
            
            if (response) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.branchNamesPicker reloadAllComponents];
                    [self switchToRegistrationView:sender];
                });
            }
            else
                [self.branchNamesPicker reloadAllComponents];
            
        }];
    }
    else
    {
        [self switchToRegistrationView:sender];
    }
}

- (void)switchToRegistrationView:(UIBarButtonItem *)sender
{
    sender.title = self.isRegistrationModeActive?@"Registration":@"Login";
    
    [self.accountNameTxt setDelegate:nil];
    [self.passcodeTxt setDelegate:nil];
    [self.emailsTxt setDelegate:nil];
    
    self.isRegistrationModeActive = !self.isRegistrationModeActive;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView reloadData];
    
    [self.accountNameTxt setDelegate:self];
    [self.passcodeTxt setDelegate:self];
    [self.emailsTxt setDelegate:self];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender
{
    if (!self.isRegistrationModeActive && [self.accountNameTxt.text length] && [self.passcodeTxt.text length]) {
        [self startLoginRequest];
    } else if (self.isRegistrationModeActive &&
               [self.accountNameTxt.text length] && [self.passcodeTxt.text length] &&
               [self.branches.branches count] && [self.emailsTxt.text length])
    {
        [self startRegistrationRequest];
    }
    else
    {
        [Utillities showBasicInputError];
    }
}

-(void)handleRegistrationCompleteWithData:(NSDictionary *)data
{
    Account *acc = [Account AccountWithProperties:data];
    [self.presentingController setAccountInfo:acc];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.presentingController didDismissLoginViewController];
    }];
}
-(void)handleRegistrationFailedWithError:(NSError *)error
{
    UIAlertView *alert = [Utillities alertViewWithTitle:error.domain
                                                message:error.userInfo[@"message"]
                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text length]) {
        [textField becomeFirstResponder];
        UIAlertView * alert = [Utillities alertViewWithTitle:@"Error" message:@"All fields are required" delegate:nil
                     cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    if ([textField isEqual:self.emailsTxt] && ![self validateEmail:textField.text]) {
        UIAlertView * alert = [Utillities alertViewWithTitle:@"Invalid Email" message:@"Please enter a valid email id" delegate:nil
                                           cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.accountNameTxt]) {
        [self.passcodeTxt becomeFirstResponder];
    }
    else if ([textField isEqual:self.passcodeTxt])
    {
        [self.emailsTxt becomeFirstResponder];
    }
    else if ([textField isEqual:self.emailsTxt])
    {
        [self.branchNamesPicker becomeFirstResponder];
        [textField resignFirstResponder];
    }
    return [textField.text length];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger charLimit = NSIntegerMax;
    // allow backspace
    if (!string.length)
    {
        return YES;
    }
    
    // Prevent invalid character input, based on the keyboard type
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        charLimit = 4;
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            return NO;
        }
    }
    else if (textField.keyboardType == UIKeyboardTypeNamePhonePad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only alphanumeric entries.");
            return NO;
        }
    }
    else if (textField.keyboardType == UIKeyboardTypePhonePad)
    {
        charLimit = 10;
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            return NO;
        }
    }
    else if (textField.keyboardType == UIKeyboardTypeEmailAddress)
    {
    }
    // verify max length has not been exceeded
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (updatedText.length > charLimit) // 4 was chosen for SSN verification
    {
        // suppress the max length message only when the user is typing
        // easy: pasted data has a length greater than 1; who copy/pastes one character?
        if (string.length > 1)
        {
            // BasicAlert(@"", @"This field accepts a maximum of 4 characters.");
        }
        
        return NO;
    }
    
    return YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[self.branches branches] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Branch *b = [self.branches.branches objectAtIndex:row];
    return b.name;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (indexPath.row==4)
        height = 162;
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isRegistrationModeActive?5:2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableViewCells objectAtIndex:indexPath.row];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.isRegistrationModeActive?@"Register for a new account":@"Login to your existing account";
}

@end
