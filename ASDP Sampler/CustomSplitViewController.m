//
// Created by Jeremy White on 8/20/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "CustomSplitViewController.h"
#import "DetailViewController.h"


@implementation CustomSplitViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;
}

- (DetailViewController *)detailViewController
{
    id viewController = [[self.viewControllers lastObject] topViewController];

    if ([viewController isKindOfClass:[DetailViewController class]])
        return viewController;
    else
        return nil;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    if (!self.detailViewController)
        return;

    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.detailViewController.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (!self.detailViewController)
        return;

    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.detailViewController.masterPopoverController = nil;
}

@end
