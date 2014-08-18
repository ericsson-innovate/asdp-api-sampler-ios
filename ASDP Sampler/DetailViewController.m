//
//  DetailViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
//    NSString *username = @"provider";
//    NSString *password = @"1234";
//    NSString *authString = [NSString stringWithFormat:@"%@:%@", username, password];
//    NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
//    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
//
//    NSString *bodyString = @"{}";
//    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSString *requestPath = @"http://lightning.att.io:3000/remoteservices/v1/vehicle/engineOn/1234";
//    NSURL *requestURL = [NSURL URLWithString:requestPath];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
//    [request setHTTPMethod:@"POST"];
//    [request setAllHTTPHeaderFields:@{
//                                      @"Authorization" : authorization,
//                                      @"APIKey" : @"1234",
//                                      @"Content-Type" : @"application/json"
//                                      }];
//    [request setHTTPBody:bodyData];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
