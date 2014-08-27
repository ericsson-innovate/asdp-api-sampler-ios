//
//  ResultsViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/21/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "ResultsViewController.h"
#import "ASDPResult.h"
#import "DetailViewController.h"
#import "APIManager.h"
#import "APICategory.h"

@class DetailViewController;

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

        if (result.data && [result.data isKindOfClass:[NSDictionary class]])
            self.getRequestStatusItem.enabled = result.data[@"requestId"] != nil;
        else
            self.getRequestStatusItem.enabled = NO;
    } else
    {
        self.requestStatusLabel.text = @"Unknown";
        self.outputTextView.text = @"";
        self.headersSwitch.enabled = NO;
        self.transactionSwitch.enabled = NO;
        self.getRequestStatusItem.enabled = NO;
    }

    _result = result;

    [self updateOutputTextView];
}

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

- (IBAction)getRequestStatus:(id)sender
{
    APISpec *requestStatusSpec = [[APIManager sharedManager] specs][@"2.6.10"];

    if (!requestStatusSpec)
        return;

    [requestStatusSpec.routeParams enumerateObjectsUsingBlock:^(RouteParam *param, NSUInteger idx, BOOL *stop) {
        if ([param.name isEqualToString:@"requestId"])
        {
            param.defaultValue = self.result.data[@"requestId"];
            *stop = YES;
        }
    }];

    NSString *storyboardName;

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        storyboardName = @"Main_iPad";
    else
        storyboardName = @"Main_iPhone";

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    DetailViewController *requestStatusViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [requestStatusViewController setDetailItem:requestStatusSpec];
    [self.navigationController pushViewController:requestStatusViewController animated:YES];
}

- (void) updateOutputTextView
{
    [self.outputTextView setText:@""];

    if (!_result)
        return;

    if (self.headersSwitch.isOn)
    {
        if (self.transactionSwitch.selectedSegmentIndex == 0 && _result.request)
        {
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:_result.request.HTTPMethod];
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@" "];
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:_result.request.URL.absoluteString];
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@"\n"];
        } else
        {
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:[NSString stringWithFormat:@"%d", _result.statusCode]];
            self.outputTextView.text = [self.outputTextView.text stringByAppendingString:@"\n"];
        }

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
