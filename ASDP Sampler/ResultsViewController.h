//
//  ResultsViewController.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/21/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionSwitch;
@property (weak, nonatomic) IBOutlet UILabel *requestStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *headersSwitch;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;

- (IBAction)toggleHeaders:(id)sender;
- (IBAction)toggleOutput:(id)sender;

@end
