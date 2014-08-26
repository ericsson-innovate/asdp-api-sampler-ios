//
//  APISpec.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "APISpecRaw.h"

@implementation APISpecRaw

+ (id) fromJSONObject:(NSDictionary *)json
{
    APISpecRaw *rawSpec = [[APISpecRaw alloc] init];
    rawSpec.identifier = json[@"id"];
    rawSpec.name = json[@"name"];
    rawSpec.desc = json[@"description"];
    rawSpec.docNumber = json[@"docNumber"];
    rawSpec.categories = json[@"categories"];
    rawSpec.resourceTable = [ResourceTable fromJSONObject:json[@"resourceTable"]];
    rawSpec.parameters = [Parameters fromJSONObject:json[@"parameters"]];

    return rawSpec;
}

- (NSDictionary *) toJSONObject
{
    return @{
            @"id" : self.identifier,
            @"name" : self.name,
            @"desc" : self.desc,
            @"docNumber" : self.docNumber,
            @"categories" : self.categories,
            @"resourceTable" : [self.resourceTable toJSONObject],
            @"parameters" : [self.parameters toJSONObject]
    };
}

- (NSString *) description
{
    id json = [self toJSONObject];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation ResourceTable

+ (id) fromJSONObject:(NSDictionary *)json
{
    ResourceTable *resourceTable = [[ResourceTable alloc] init];
    resourceTable.route = json[@"Route"];
    resourceTable.verbs = json[@"HTTP Verb"];

    return resourceTable;
}

- (id) toJSONObject
{
    return @{
            @"Route" : self.route,
            @"HTTP Verb" : self.verbs
    };
}

- (NSString *) description
{
    id json = [self toJSONObject];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation Parameters

+ (id) fromJSONObject:(NSDictionary *)json
{
    NSDictionary *rawRouteParams = json[@"route"];
    NSMutableArray *routeParams = [NSMutableArray new];

    [rawRouteParams enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *desc, BOOL *stop) {
        RouteParam *routeParam = [[RouteParam alloc] init];
        routeParam.name = name;
        routeParam.desc = desc;
        [routeParams addObject:routeParam];
    }];

    NSArray *rawRequestParams = json[@"requestBody"];
    NSMutableArray *requestParams = [NSMutableArray new];

    [rawRequestParams enumerateObjectsUsingBlock:^(NSDictionary *rawRequestParam, NSUInteger idx, BOOL *stop) {
        RequestParam *requestParam = [RequestParam fromJSONObject:rawRequestParam];

        if (requestParam)
            [requestParams addObject:requestParam];
    }];

    Parameters *parameters = [[Parameters alloc] init];
    parameters.route = [NSArray arrayWithArray:routeParams];
    parameters.requestBody = [NSArray arrayWithArray:requestParams];

    return parameters;
}

- (id) toJSONObject
{
    NSMutableArray *requestBody = [NSMutableArray new];

    [self.requestBody enumerateObjectsUsingBlock:^(RequestParam *requestParam, NSUInteger idx, BOOL *stop) {
        [requestBody addObject:[requestParam toJSONObject]];
    }];

    return [NSArray arrayWithArray:requestBody];
}

- (NSString *) description
{
    id json = [self toJSONObject];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation RouteParam

@end

@implementation RequestParam

+ (id) fromJSONObject:(NSDictionary *)json
{
    RequestParam *requestParam = [[RequestParam alloc] init];
    requestParam.key = json[@"key"];
    requestParam.type = json[@"type"];
    requestParam.required = [json[@"required"] boolValue];
    requestParam.desc = json[@"description"];
    requestParam.defaultValue = json[@"defaultVal"];

    return requestParam;
}

- (id) toJSONObject
{
    return @{
            @"key" : self.key,
            @"type" : self.type,
            @"required" : @(self.required),
            @"description" : self.desc,
            @"defaultVal" : self.defaultValue
    };
}

- (NSString *) description
{
    id json = [self toJSONObject];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
