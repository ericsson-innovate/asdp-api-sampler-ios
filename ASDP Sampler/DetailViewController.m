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
@property (weak, nonatomic) IBOutlet UITableView *parametersTableView;

// constraints
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailDescriptionTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailDescriptionLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailDescriptionRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *initialTableViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *keyboardTableViewTopConstraint;

// actions
- (void)configureView;

@end

@implementation DetailViewController
{
    UILabel *_initialView;
    NSMutableDictionary *_routeParams;
    NSMutableDictionary *_requestParams;
    ASDPResult *_lastResult;

    NSMutableArray *_routeParamTextFields;
    NSMutableArray *_requestParamTextFields;
    
    BOOL _adjustedForKeyboard;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(sendData:)];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];

    _routeParamTextFields = [NSMutableArray new];
    _requestParamTextFields = [NSMutableArray new];

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

            self.detailDescriptionTextView.text = [NSString stringWithFormat:@"[%@] %@", self.detailItem.docNumber, self.detailItem.desc];
            
            [self.parametersTableView setDataSource:self];
            [self.parametersTableView setDelegate:self];
            [self.parametersTableView reloadData];

            self.navigationItem.rightBarButtonItem = _sendItem;
            self.navigationItem.rightBarButtonItem.enabled = [[APIManager sharedManager] isSupported:_detailItem];
            break;

        case DetailStateLoading:
            self.navigationItem.rightBarButtonItem.enabled = NO;
            _parametersTableView.userInteractionEnabled = NO;
            break;

        case DetailStateComplete:
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _parametersTableView.userInteractionEnabled = YES;
            break;
            
        default:break;
    }
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(APISpec *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;

        _routeParams = [NSMutableDictionary new];
        _requestParams = [NSMutableDictionary new];

        [_detailItem.requestParams enumerateObjectsUsingBlock:^(RequestParam *requestParam, NSUInteger idx, BOOL *stop) {
            if (requestParam.defaultValue)
                _requestParams[requestParam.key] = requestParam.defaultValue;
        }];

        [_detailItem.routeParams enumerateObjectsUsingBlock:^(RouteParam *routeParam, NSUInteger idx, BOOL *stop) {
            if (routeParam.defaultValue)
                _routeParams[routeParam.name] = routeParam.defaultValue;
            else
            {
                if ([@"vin" isEqualToString:routeParam.name])
                    _routeParams[@"vin"] = [[ASDPRequestManager sharedManager] vin];
            }
        }];

        self.state = DetailStateStart;

        if (self.resultsViewController)
            [self.resultsViewController setResult:nil];
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
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.detailItem && self.detailItem.routeParams)
            return self.detailItem.routeParams.count;
        else
            return 0;
    } else
    {
        if (self.detailItem && self.detailItem.requestParams)
            return self.detailItem.requestParams.count;
        else
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Route Parameters";
    else
        return @"Request Parameters";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell" forIndexPath:indexPath];

    NSString *title;
    NSString *desc;
    BOOL req;

    if (indexPath.section == 0)
    {
        RouteParam *param = self.detailItem.routeParams[indexPath.row];
        title = param.name;
        desc = param.desc;
        req = YES;
    } else
    {
        RequestParam *param = self.detailItem.requestParams[indexPath.row];
        title = param.key;
        desc = param.desc;
        req = param.required;
    }

    UILabel *paramTitleLabel = (UILabel *) [cell.contentView viewWithTag:101];
    UILabel *paramDescLabel = (UILabel *) [cell.contentView viewWithTag:102];

    paramTitleLabel.text = title;
    paramDescLabel.text = desc;

    UITextField *valueTextField = (UITextField *) [cell.contentView viewWithTag:103];
    [valueTextField setPlaceholder:title];
    [valueTextField setDelegate:self];

    [_requestParamTextFields removeObject:valueTextField];
    [_routeParamTextFields removeObject:valueTextField];

    NSString *defaultValue;

    if (indexPath.section == 0)
    {
        [_routeParamTextFields addObject:valueTextField];

        if (_routeParams[title])
            defaultValue = [NSString stringWithFormat:@"%@", _routeParams[title]];
    } else
    {
        [_requestParamTextFields addObject:valueTextField];

        if (_requestParams[title])
            defaultValue = [NSString stringWithFormat:@"%@", _requestParams[title]];
    }

    valueTextField.text = defaultValue;

    UILabel *requiredLabel = (UILabel *) [cell.contentView viewWithTag:104];
    requiredLabel.text = req ? @"(required)" : @"(optional)";

    return cell;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self makeWayForKeyboard:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeWayForKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSMutableDictionary *params;

    if ([_routeParamTextFields containsObject:textField])
        params = _routeParams;
    else if ([_requestParamTextFields containsObject:textField])
        params = _requestParams;

    if (params)
    {
        if (textField.text && textField.text.length > 0)
            params[textField.placeholder] = textField.text;
        else
            [params removeObjectForKey:textField.placeholder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard UI adjustments

- (void) makeWayForKeyboard:(NSNotification *)notification
{
    if (_adjustedForKeyboard)
        return;
    
    if (notification)
    {
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.parametersTableView.contentInset = contentInsets;
        self.parametersTableView.scrollIndicatorInsets = contentInsets;
        
        _adjustedForKeyboard = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDismissal:) name:UIKeyboardDidHideNotification object:nil];
    } else {
        [self.view removeConstraint:self.initialTableViewTopConstraint];
        [self.view removeConstraint:self.detailDescriptionTopConstraint];
        [self.view removeConstraint:self.detailDescriptionLeftConstraint];
        [self.view removeConstraint:self.detailDescriptionRightConstraint];
        
        [self.detailDescriptionTextView removeFromSuperview];
        
        if (!self.keyboardTableViewTopConstraint)
            self.keyboardTableViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.parametersTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.view addConstraint:self.keyboardTableViewTopConstraint];
    }
}

- (void) handleKeyboardDismissal:(NSNotification *)notification
{
    if (!_adjustedForKeyboard)
        return;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.parametersTableView.contentInset = contentInsets;
    self.parametersTableView.scrollIndicatorInsets = contentInsets;
    
    [self.view removeConstraint:self.keyboardTableViewTopConstraint];
    [self.view addSubview:self.detailDescriptionTextView];
    
    self.initialTableViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.parametersTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.detailDescriptionTextView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0];
    
    self.detailDescriptionTopConstraint = [NSLayoutConstraint constraintWithItem:self.detailDescriptionTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:8.0];
    
    self.detailDescriptionLeftConstraint = [NSLayoutConstraint constraintWithItem:self.detailDescriptionTextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:16.0];
    
    self.detailDescriptionRightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.detailDescriptionTextView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:16.0];
    
    [self.view addConstraint:self.initialTableViewTopConstraint];
    [self.view addConstraint:self.detailDescriptionTopConstraint];
    [self.view addConstraint:self.detailDescriptionLeftConstraint];
    [self.view addConstraint:self.detailDescriptionRightConstraint];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    _adjustedForKeyboard = NO;
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

    NSMutableDictionary *requestParameters = [NSMutableDictionary new];

    [_requestParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        unichar firstChar = [value characterAtIndex:0];

        NSError *jsonError;
        id textObject;

        if (firstChar == '[' || firstChar == '{')
        {
            NSData *textData = [value dataUsingEncoding:NSUTF8StringEncoding];
            textObject = [NSJSONSerialization JSONObjectWithData:textData options:0 error:&jsonError];
        }

        if (textObject && !jsonError)
            requestParameters[key] = textObject;
        else
            requestParameters[key] = value;
    }];

    [[ASDPRequestManager sharedManager] executeAPI:self.detailItem routeParams:_routeParams requestParams:requestParameters completion:^(ASDPResult *result) {
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
