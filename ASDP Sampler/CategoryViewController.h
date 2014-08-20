//
// Created by Jeremy White on 8/18/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"

@class DetailViewController;
@class APICategory;

@interface CategoryViewController : UITableViewController

@property (strong, nonatomic, readonly) DetailViewController *detailViewController;
@property (strong, nonatomic) APICategory *category;

@end
