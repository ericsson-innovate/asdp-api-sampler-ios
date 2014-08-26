//
//  APIManager.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "APIManager.h"
#import "APISpec.h"
#import "APICategory.h"
#import "ASDPRequestManager.h"

@implementation APIManager

- (id) init
{
    self = [super init];

    if (self)
    {
        self.state = APIManagerStateInitial;
    }

    return self;
}

+ (APIManager *)sharedManager
{
    static APIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!_sharedManager)
            _sharedManager = [[APIManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)loadSpecs
{
    if (!self.categories || self.categories.count == 0)
    {
        [self loadSpecsFromRemoteJSON:kRemoteAPISpecURL];
    }
}

- (void)loadSpecsFromRemoteJSON:(NSURL *)jsonURL
{
    self.state = APIManagerStateFetching;

    NSURLRequest *request = [NSURLRequest requestWithURL:jsonURL];

    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error || !response || !responseData)
    {
        self.state = APIManagerStateError;
        [[[UIAlertView alloc] initWithTitle:@"Experienced Error Downloading API Specs" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else
    {
        self.state = APIManagerStateParsing;

        NSArray *rawSpecData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];

        if (error || !rawSpecData)
        {
            self.state = APIManagerStateError;
            [[[UIAlertView alloc] initWithTitle:@"Experienced Error Parsing API Specs" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else
        {
            NSMutableDictionary *specDictionary = [NSMutableDictionary new];
            NSMutableDictionary *allSpecs = [NSMutableDictionary new];

            [rawSpecData enumerateObjectsUsingBlock:^(NSDictionary *specJSON, NSUInteger specIdx, BOOL *specStop) {
                APISpecRaw *rawSpec = [APISpecRaw fromJSONObject:specJSON];
                APISpec *spec = [[APISpec alloc] initWithAPISpecRaw:rawSpec];

                allSpecs[spec.docNumber] = spec;

                [rawSpec.categories enumerateObjectsUsingBlock:^(NSString *category, NSUInteger categoryIdx, BOOL *categoryStop) {
                    NSMutableArray *specs = specDictionary[category];

                    if (!specs)
                    {
                        specs = [NSMutableArray new];
                        specDictionary[category] = specs;
                    }

                    [specs addObject:spec];
                }];
            }];

            // Make everything immutable

            _specs = [NSDictionary dictionaryWithDictionary:allSpecs];

            NSMutableArray *categories = [NSMutableArray new];

            [specDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *category, NSMutableArray *specs, BOOL *stop) {
                APICategory *apiCategory = [[APICategory alloc] init];
                apiCategory.name = category;
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                apiCategory.specs = [specs sortedArrayUsingDescriptors:@[sort]];

                [categories addObject:apiCategory];
            }];

            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            _categories = [categories sortedArrayUsingDescriptors:@[sort]];

            self.state = APIManagerStateComplete;
        }
    }
}

- (BOOL) isSupported:(APISpec *)spec
{
    SEL apiSelector = [APIManager selectorForAPISpec:spec];
    return apiSelector && [[ASDPRequestManager sharedManager] respondsToSelector:apiSelector];
}

+ (SEL) selectorForAPISpec:(APISpec *)spec
{
    NSString *formattedAPIName = [self convertAPINameToSelectorName:spec];
    NSString *apiSelectorName = [NSString stringWithFormat:@"%@:completion:", formattedAPIName];
    return NSSelectorFromString(apiSelectorName);
}

+ (NSString *) convertAPINameToSelectorName:(APISpec *)spec
{
    NSString *specName = spec.name;

    NSMutableString *selectorName = [NSMutableString new];
    BOOL shouldCapitalize = NO;

    for (int i = 0; i < specName.length; ++i)
    {
        int current = [specName characterAtIndex:i];

        if (current == ' ' || current == '-' || current == '_')
        {
            shouldCapitalize = YES;
            continue;
        } else
        {
            NSString *charToAdd = [NSString stringWithFormat:@"%c", current];

            if (shouldCapitalize)
            {
                charToAdd = [charToAdd uppercaseString];
                shouldCapitalize = NO;
            }

            if (i == 0)
                charToAdd = [charToAdd lowercaseString];

            [selectorName appendString:charToAdd];
        }
    }

    return selectorName;
}

@end
