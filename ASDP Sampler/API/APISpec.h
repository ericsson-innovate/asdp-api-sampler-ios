//
//  APISpec.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APISpecRaw.h"
#import "JSONObjectCoding.h"

@interface APISpec : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *docNumber;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, readonly) NSString *route;
@property (nonatomic, readonly) NSArray *routeParams;
@property (nonatomic, readonly) NSArray *requestParams;
@property (nonatomic, readonly) NSString *verb;

- (instancetype) initWithAPISpecRaw:(APISpecRaw *)apiSpecRaw;
- (BOOL) isValid;

@end
