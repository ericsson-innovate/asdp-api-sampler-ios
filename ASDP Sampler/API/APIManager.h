//
//  APIManager.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APISpecRaw.h"

#define kRemoteAPISpecURL [NSURL URLWithString:@"https://ericsson-innovate.github.io/hackathon-portal/dist/data/specifications.json"]

@interface APIManager : NSObject

enum {
    APIManagerStateInitial = 0,
    APIManagerStateFetching,
    APIManagerStateParsing,
    APIManagerStateComplete,
    APIManagerStateError
};

typedef NSUInteger APIManagerState;

+ (APIManager *) sharedManager;

- (void) loadSpecs;
- (BOOL) isSupported:(APISpecRaw *)spec;
- (NSHTTPURLResponse *) executeAPI:(APISpecRaw *)spec params:(NSDictionary *)params request:(NSURLRequest **)request error:(NSError **)error;

@property (nonatomic, strong, readonly) NSArray *categories;
@property (nonatomic, readonly) APIManagerState state;

@end
