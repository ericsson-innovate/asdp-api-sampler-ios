//
// Created by Jeremy White on 8/18/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "CategoryViewController.h"
#import "APIManager.h"
#import "APICategory.h"
#import "APISpec.h"
#import "DetailViewController.h"

@implementation CategoryViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (DetailViewController *)detailViewController
{
    id viewController = [[self.splitViewController.viewControllers lastObject] topViewController];
    
    if ([viewController isKindOfClass:[DetailViewController class]])
        return viewController;
    else
        return nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.category && self.category.specs)
        return self.category.specs.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    APISpec *spec = self.category.specs[indexPath.row];
    cell.textLabel.text = spec.name;

    return cell;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        APISpec *spec = self.category.specs[indexPath.row];
        
        if (self.detailViewController)
            self.detailViewController.detailItem = spec;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([[segue identifier] isEqualToString:@"showDetail"] && [segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        APISpec *spec = self.category.specs[indexPath.row];
//        [((DetailViewController *) [segue destinationViewController]) setDetailItem:spec];
//    }
}

@end
