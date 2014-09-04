//
//  DetailViewController.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APISpec.h"


@interface DetailViewController : UIViewController
enum {
    DetailStateInitial = 0,
    DetailStateStart,
    DetailStateLoading,
    DetailStateComplete,
    DetailStateCompleteWithAction
};
typedef NSUInteger DetailState;

@property (nonatomic) DetailState state;
@property (strong, nonatomic) APISpec *detailItem;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) IBOutlet UITextView *detailDescriptionTextView;

@end
