//
//  DetailViewController.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APISpec.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) APISpec *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
