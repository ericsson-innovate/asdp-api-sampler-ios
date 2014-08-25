//
//  DetailViewController.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/13/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "DetailViewController.h"
#import "ResultsViewController.h"
#import "ASDPRequestManager.h"
#import "APIManager.h"


@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UIBarButtonItem *sendItem;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) ResultsViewController *resultsViewController;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *parametersTableView;

- (void)configureView;

@end

@implementation DetailViewController
{
    UILabel *_initialView;
    NSMutableDictionary *_storedValues;
    ASDPResult *_lastResult;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendData:)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    self.state = DetailStateInitial;
}

- (void) setState:(DetailState)state
{
    _state = state;
    
    [self configureView];
}

- (void) configureView
{
    switch (self.state)
    {
        case DetailStateInitial:
            [self.titleItem setTitle:@""];

            _initialView = [[UILabel alloc] initWithFrame:self.view.bounds];
            [_initialView setTag:99];
            [_initialView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [_initialView setTextAlignment:NSTextAlignmentCenter];
            [_initialView setText:@"Select an API to begin"];
            [_initialView setBackgroundColor:[UIColor whiteColor]];

            [self.view addSubview:_initialView];
            break;

        case DetailStateStart:
            if (!_initialView)
                _initialView = (UILabel *) [self.view viewWithTag:99];
            
            if (_initialView)
            {
                [_initialView removeFromSuperview];
                _initialView = nil;
            }

            [self.titleItem setTitle:self.detailItem.name];

            self.descriptionLabel.text = [NSString stringWithFormat:@"[%@] %@", self.detailItem.docNumber, self.detailItem.desc];
            self.descriptionLabel.numberOfLines = 0;
            [self.descriptionLabel sizeToFit];

            [self.view setNeedsUpdateConstraints];
            [self.view setNeedsLayout];
            
            [self.parametersTableView setDataSource:self];
            [self.parametersTableView setDelegate:self];
            [self.parametersTableView reloadData];

            self.navigationItem.rightBarButtonItem = _sendItem;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;

        case DetailStateLoading:
            self.navigationItem.rightBarButtonItem.enabled = NO;
            break;

        case DetailStateComplete:
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
            
        default:break;
    }
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(APISpec *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        _storedValues = [NSMutableDictionary new];

        [_detailItem.requestParams enumerateObjectsUsingBlock:^(RequestParam *requestParam, NSUInteger idx, BOOL *stop) {
            if (requestParam.defaultValue)
                _storedValues[requestParam.key] = requestParam.defaultValue;
        }];

        self.state = DetailStateStart;
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }

    [self.parametersTableView reloadData];
}

#pragma mark - Table View Delegate

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.detailItem)
        return self.detailItem.requestParams.count;
    else
        return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];

    RequestParam *param = self.detailItem.requestParams[indexPath.row];

    UILabel *paramTitleLabel = (UILabel *) [cell.contentView viewWithTag:101];
    UILabel *paramDescLabel = (UILabel *) [cell.contentView viewWithTag:102];

    paramTitleLabel.text = param.key;
    paramDescLabel.text = param.desc;

    UITextField *valueTextField = (UITextField *) [cell.contentView viewWithTag:103];
    [valueTextField setPlaceholder:param.key];
    [valueTextField setDelegate:self];
    valueTextField.text = _storedValues[param.key];

    if (param.required)
    {
        UILabel *requiredLabel = (UILabel *) [cell.contentView viewWithTag:104];
        requiredLabel.text = @"(required)";
    }

    return cell;
}

// TODO: respond to keyboard events for iPhone, mostly

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text && textField.text.length > 0)
        _storedValues[textField.placeholder] = textField.text;
    else
        [_storedValues removeObjectForKey:textField.placeholder];
}

#pragma mark - Actions

- (ResultsViewController *) resultsViewController
{
    if (!_resultsViewController)
    {
        [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
            if ([viewController isKindOfClass:ResultsViewController.class])
            {
                _resultsViewController = (ResultsViewController *) viewController;
                *stop = YES;
            }
        }];
    }

    return _resultsViewController;
}

- (void) sendData:(id)sender
{
    self.state = DetailStateLoading;

    [[ASDPRequestManager sharedManager] executeAPI:self.detailItem params:_storedValues completion:^(ASDPResult *result) {
        _lastResult = result;

        self.state = DetailStateComplete;

        if (self.resultsViewController)
            [self.resultsViewController setResult:_lastResult];
        else
            [self performSegueWithIdentifier:@"showResults" sender:self];
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showResults"] && [segue.destinationViewController isKindOfClass:ResultsViewController.class])
    {
        [((ResultsViewController *)segue.destinationViewController) setResult:_lastResult];
    }
}

@end
