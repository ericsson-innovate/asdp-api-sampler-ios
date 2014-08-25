//
//  ResultsViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/21/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "ResultsViewController.h"
#import "ASDPResult.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setResult:_result];
}

- (void) setResult:(ASDPResult *)result
{
    if (result)
    {
        self.requestStatusLabel.text = [NSString stringWithFormat:@"%d", result.statusCode];
        self.headersSwitch.enabled = YES;
        self.transactionSwitch.enabled = YES;
    } else
    {
        self.requestStatusLabel.text = @"Unknown";
        self.outputTextView.text = @"";
        self.headersSwitch.enabled = NO;
        self.transactionSwitch.enabled = NO;
    }

    _result = result;

    [self updateOutputTextView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)toggleHeaders:(id)sender {
    if (!self.result)
        return;

    [self updateOutputTextView];
}

- (IBAction)toggleOutput:(id)sender {
    if (!self.result)
        return;
    
    [self updateOutputTextView];
}

- (void) updateOutputTextView
{
    [self.outputTextView setText:@""];

    if (!_result)
        return;

    if (self.headersSwitch.isOn)
    {
        NSDictionary *headers;
        
        if (self.transactionSwitch.selectedSegmentIndex == 0)
            headers = _result.request.allHTTPHeaderFields;
        else
            headers = _result.response.allHeaderFields;
        
        if (headers && headers.count > 0)
        {
            [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                self.outputTextView.text = [self.outputTextView.text stringByAppendingString:key];
                self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@": "];
                self.outputTextView.text = [self.outputTextView.text stringByAppendingString:value];
                self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@"\n"];
            }];
            
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@"\n"];
        }
    }

    if (self.transactionSwitch.selectedSegmentIndex == 0)
    {
        if (_result && _result.request && _result.request.HTTPBody && _result.request.HTTPBody.length > 0)
        {
            NSString *requestBody = [[NSString alloc] initWithData:_result.request.HTTPBody encoding:NSUTF8StringEncoding];
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:requestBody];
        }
    } else
    {
        if (_result && _result.body)
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:_result.body];
    }
}

@end
