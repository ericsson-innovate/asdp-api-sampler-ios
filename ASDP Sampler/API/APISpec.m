//
//  APISpec.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "APISpec.h"

@implementation APISpec
{
    APISpecRaw *_apiSpecRaw;
}

- (instancetype) initWithAPISpecRaw:(APISpecRaw *)apiSpecRaw
{
    self = [super init];
    
    if (self)
    {
        _apiSpecRaw = apiSpecRaw;
        
        _name = _apiSpecRaw.name;
        _desc = _apiSpecRaw.desc;
        _docNumber = _apiSpecRaw.docNumber;
        _identifier = _apiSpecRaw.identifier;
        _categories = _apiSpecRaw.categories;
    }
    
    return self;
}

- (NSString *) route
{
    if (_apiSpecRaw)
        return _apiSpecRaw.resourceTable.route;
    
    return nil;
}

- (NSString *) verb
{
    if (_apiSpecRaw &&
        _apiSpecRaw.resourceTable &&
        _apiSpecRaw.resourceTable.verbs &&
        _apiSpecRaw.resourceTable.verbs.count > 0)
    {
        NSString *verb = _apiSpecRaw.resourceTable.verbs[0];

        if ([@"GET" isEqualToString:verb] || [@"POST" isEqualToString:verb])
            return verb;
    }
    
    return nil;
}

- (NSArray *) routeParams
{
    if (_apiSpecRaw &&
            _apiSpecRaw.parameters &&
            _apiSpecRaw.parameters.route &&
            _apiSpecRaw.parameters.route.count > 0)
    {
        return _apiSpecRaw.parameters.route;
    }

    return nil;
}

- (NSArray *) requestParams
{
    if (_apiSpecRaw &&
        _apiSpecRaw.parameters &&
        _apiSpecRaw.parameters.requestBody &&
        _apiSpecRaw.parameters.requestBody.count > 0)
    {
        return _apiSpecRaw.parameters.requestBody;
    }

    return nil;
}

- (BOOL) isValid
{
    return ![self isEmpty:self.name] &&
            ![self isEmpty:self.identifier] &&
            ![self isEmpty:self.desc] &&
            ![self isEmpty:self.docNumber] &&
            _categories != nil && _categories.count > 0;
}

- (BOOL) isEmpty:(NSString *)string
{
    return string != nil && string.length > 0;
}

+ (id) fromJSONObject:(NSDictionary *)json
{
    // // we don't need to implement this method
    return nil;
}

- (id) toJSONObject
{
    return [_apiSpecRaw toJSONObject];
}

- (NSString *) description
{
    return [_apiSpecRaw description];
}

@end
