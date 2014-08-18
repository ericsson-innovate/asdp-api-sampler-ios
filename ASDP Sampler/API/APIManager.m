//
//  APIManager.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "APIManager.h"
#import "APISpec.h"

@implementation APIManager

+ (APIManager *)sharedManager
{
    static APIManager *_sharedHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!_sharedHelper)
            _sharedHelper = [[APIManager alloc] init];
    });
    
    return _sharedHelper;
}

- (void)loadSpecs
{
    if (!self.specDictionary || self.specDictionary.count == 0)
    {
        [self loadSpecsFromRemoteJSON:kRemoteAPISpecURL];
    }
}

- (void)loadSpecsFromRemoteJSON:(NSURL *)jsonURL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:jsonURL];

    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error || !response)
    {
        [[[UIAlertView alloc] initWithTitle:@"Experienced Error Downloading API Specs" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;

        NSArray *rawSpecData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];

        if (error || !rawSpecData)
        {
            [[[UIAlertView alloc] initWithTitle:@"Experienced Error Parsing API Specs" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else
        {
            NSMutableDictionary *specDictionary = [NSMutableDictionary new];

            [rawSpecData enumerateObjectsUsingBlock:^(NSDictionary *specJSON, NSUInteger specIdx, BOOL *specStop) {
                APISpecRaw *rawSpec = [APISpecRaw fromJSONObject:specJSON];
                APISpec *spec = [[APISpec alloc] initWithAPISpecRaw:rawSpec];

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

            [specDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *category, NSMutableArray *specs, BOOL *stop) {
                specDictionary[category] = [NSArray arrayWithArray:specs];
            }];

            _specDictionary = [NSMutableDictionary dictionaryWithDictionary:specDictionary];
        }
    }
}

- (BOOL) isSupported:(APISpecRaw *)spec
{
    // TODO: use reflection to find method for the provided spec
    return NO;
}

- (NSHTTPURLResponse *) executeAPI:(APISpecRaw *)spec params:(NSDictionary *)params request:(NSURLRequest **)request error:(NSError **)error
{
    return nil;
}

@end
