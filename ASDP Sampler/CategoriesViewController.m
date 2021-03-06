//
//  CategoriesViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "CategoriesViewController.h"
#import "APIManager.h"
#import "APICategory.h"
#import "CategoryViewController.h"
#import "ASDPRequestManager.h"
#import "AppDelegate.h"

@implementation CategoriesViewController
{
    BOOL hasAddedObserver;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hasAddedObserver = NO;

    if ([APIManager sharedManager].state != APIManagerStateComplete)
    {
        [[APIManager sharedManager] addObserver:self forKeyPath:@"state" options:0 context:nil];
        hasAddedObserver = YES;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([APIManager sharedManager].state == APIManagerStateComplete)
    {
        if (hasAddedObserver)
        {
            @try {
                [[APIManager sharedManager] removeObserver:self forKeyPath:@"state"];
                hasAddedObserver = NO;
            } @catch (__unused NSException *ex) { }
        }

        return [APIManager sharedManager].categories.count;
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell" forIndexPath:indexPath];

    APICategory *category = [APIManager sharedManager].categories[indexPath.row];
    NSString *categoryName = kAPICategoryNames[category.name];

    if (!categoryName)
        categoryName = category.name;

    cell.textLabel.text = categoryName;

    NSString *apiAmount = [NSString stringWithFormat:@"%d apis available", (int) category.specs.count];
    cell.detailTextLabel.text = apiAmount;

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
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        NSDate *object = _objects[indexPath.row];
//        self.detailViewController.detailItem = object;
//    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showCategory"] && [segue.destinationViewController isKindOfClass:[CategoryViewController class]])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        APICategory *category = [APIManager sharedManager].categories[indexPath.row];
        [((CategoryViewController *) [segue destinationViewController]) setCategory:category];
    }

//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _objects[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
//    }
}

- (IBAction)logout:(id)sender
{
    [[ASDPRequestManager sharedManager] logout];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
    mainWindow.rootViewController = appDelegate.loginViewController;
    [mainWindow makeKeyAndVisible];
}

@end
