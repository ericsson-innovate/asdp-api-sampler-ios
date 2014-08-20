//
//  CategoriesViewController.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoriesViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutItem;

- (IBAction)logout:(id)sender;

@end
