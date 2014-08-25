//
//  APIManager.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APISpec.h"
#import "ASDPRequestManager.h"

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
+ (SEL) selectorForAPISpec:(APISpec *)spec;
+ (NSString *) convertAPINameToSelectorName:(APISpec *)spec;

- (void) loadSpecs;
- (BOOL) isSupported:(APISpec *)spec;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic) APIManagerState state;

@end
