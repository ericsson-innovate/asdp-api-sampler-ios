//
//  LoginViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/19/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "LoginViewController.h"
#import "ASDPResult.h"
#import "ASDPRequestManager.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

- (IBAction)login:(id)sender;

@end

@implementation LoginViewController
{
    BOOL _requestIsLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _requestIsLoading = NO;
    
    [self updateUIState];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateUIState) withObject:nil afterDelay:0.1];

    return YES;
}

- (void) updateUIState
{
    if (_requestIsLoading)
    {
        _loginButton.enabled = NO;
        [_loginActivityIndicator startAnimating];
        
        _usernameTextField.enabled = NO;
        _passwordTextField.enabled = NO;
        _vinTextField.enabled = NO;
        
        return;
    } else
    {
        [_loginActivityIndicator stopAnimating];
    }
    
    if (_requestIsLoading ||
        !self.usernameTextField.text || self.usernameTextField.text.length == 0 ||
        !self.passwordTextField.text || self.passwordTextField.text.length == 0 ||
        !self.vinTextField.text || self.vinTextField.text.length == 0)
    {
        _loginButton.enabled = NO;
    } else
    {
        _usernameTextField.enabled = YES;
        _passwordTextField.enabled = YES;
        _vinTextField.enabled = YES;
        _loginButton.enabled = YES;
    }
}

- (IBAction)login:(id)sender
{
    _requestIsLoading = YES;

    [self updateUIState];

    NSDictionary *params = @{
            @"username" : self.usernameTextField.text,
            @"pin" : self.passwordTextField.text,
            @"vin" : self.vinTextField.text
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        ASDPResult *result = [[ASDPRequestManager sharedManager] login:params];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.isSuccess)
                [self performSegueWithIdentifier:@"loginSuccess" sender:self];
            else
                [[[UIAlertView alloc] initWithTitle:@"Error occurred" message:result.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            _requestIsLoading = NO;
            
            [self updateUIState];
        });
    });
}

@end
