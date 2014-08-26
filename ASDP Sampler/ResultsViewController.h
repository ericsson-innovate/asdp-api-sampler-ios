//
//  ResultsViewController.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/21/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASDPResult;

@interface ResultsViewController : UIViewController

@property (nonatomic, strong) ASDPResult *result;

@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *requestStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *headersSwitch;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *getRequestStatusItem;

- (IBAction)toggleHeaders:(id)sender;
- (IBAction)toggleOutput:(id)sender;
- (IBAction)getRequestStatus:(id)sender;

@end
