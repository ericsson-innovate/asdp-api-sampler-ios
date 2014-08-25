//
//  ASDPRequestManager.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/19/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "ASDPRequestManager.h"
#import "APIManager.h"

@implementation ASDPRequestManager

+ (ASDPRequestManager *)sharedManager
{
    static ASDPRequestManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        if (!_sharedManager)
            _sharedManager = [[ASDPRequestManager alloc] init];
    });

    return _sharedManager;
}

// ## START 2.6.4-login
- (void) login:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *username = params[@"username"];
        NSString *pin = params[@"pin"];
        NSString *vin = params[@"vin"];
        
        if (!username) username = @"";
        if (!pin) pin = @"";
        if (!vin) vin = @"(null)";
        
        NSString *authString = [NSString stringWithFormat:@"%@:%@", username, pin];
        NSData *authData = [authString dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authorization = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        
        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/login/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];
        [request setAllHTTPHeaderFields:@{
                                          @"Authorization" : authorization,
                                          @"APIKey" : pin,
                                          @"Content-Type" : @"application/json"
                                          }];
        
        ASDPResult *result = [self processRequest:request];

        if (result.isSuccess)
        {
            _vin = vin;
            _authToken = authorization;
            _apiKey = pin;
        }

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.4-login

- (void) logout
{
    // TODO: implement this
}

// ## START COMMON
- (NSURL *) buildURL:(NSString *)targetPath
{
    NSString *baseURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];

    if (!baseURL)
        baseURL = @"http://lightning.att.io:3000/";

    NSString *targetURL = [NSString stringWithString:baseURL];
    targetURL = [targetURL stringByAppendingPathComponent:targetPath];

    return [NSURL URLWithString:targetURL];
}

- (ASDPResult *) processRequest:(NSMutableURLRequest *)request
{
    if (!request.HTTPBody || request.HTTPBody.length == 0)
    {
        NSString *defaultBody = @"{}";
        NSData *defaultBodyData = [defaultBody dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:defaultBodyData];
    }

    NSString *contentLength = [NSString stringWithFormat:@"%d", request.HTTPBody.length];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];

    ASDPResult *result;

    NSHTTPURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (error || !response || !responseData)
    {
        if (response)
            result = [[ASDPResult alloc] initWithStatusCode:(int) response.statusCode];
        else
            result = [[ASDPResult alloc] initWithStatusCode:500];
    } else
    {
        result = [[ASDPResult alloc] initWithStatusCode:(int) response.statusCode body:responseData];
    }

    result.request = request;
    result.response = response;

    return result;
}
// ## END COMMON

- (void) executeAPI:(APISpec *)spec params:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    SEL apiSelector = [APIManager selectorForAPISpec:spec];
    [[ASDPRequestManager sharedManager] performSelector:apiSelector withObject:params withObject:completion];
}

@end
