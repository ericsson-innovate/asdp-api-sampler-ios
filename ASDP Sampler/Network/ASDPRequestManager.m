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

// ## START 2.6.1-sign-up
- (void) signUp:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/signup/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.1-sign-up

// ## START 2.6.2-validate-otp
- (void) validateOneTimePassword:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/validateotp/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        NSString *oneTimePassword = params[@"request"][@"otp"];

        if (!oneTimePassword)
            oneTimePassword = @"";

        NSDictionary *requestParams = @{
            @"otp" : oneTimePassword
        };

        ASDPResult *result = [self processRequest:request params:requestParams];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.2-validate-otp

// ## START 2.6.3-set-pin
- (void) setPIN:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/setpin/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        NSString *oneTimePassword = params[@"request"][@"otp"];
        int pin = [params[@"request"][@"pin"] integerValue];

        if (!oneTimePassword) oneTimePassword = @"";

        NSDictionary *requestParams = @{
                @"otp" : oneTimePassword,
                @"pin" : @(pin)
        };

        ASDPResult *result = [self processRequest:request params:requestParams];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.3-set-pin

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
                                          @"Content-Type" : @"application/json",
                                          @"Accept" : @"application/json"
                                          }];
        
        ASDPResult *result = [self processRequest:request params:nil];

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

// ## START 2.6.5-door-unlock
- (void) doorUnlock:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/unlock/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.5-door-unlock

// ## START 2.6.6-door-lock
- (void) doorLock:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/lock/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.6-door-lock

// ## START 2.6.7-engine-on
- (void) engineOn:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/engineOn/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.7-engine-on

// ## START 2.6.8-engine-off
- (void) engineOff:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/engineOff/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.8-engine-off

// ## START 2.6.9-honk-and-blink
- (void) honkAndBlink:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/honkBlink/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.9-honk-and-blink

// ## START 2.6.10-check-request-status
- (void) checkRequestStatus:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];
        int requestId = [params[@"route"][@"requestId"] intValue];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/status/%@/%d", vin, requestId];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"GET"];

        ASDPResult *result = [self processRequest:request params:nil];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.10-check-request-status

// ## START 2.6.11-view-diagnostic-data
- (void) viewDiagnosticData:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/diagnostics/view/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.11-view-diagnostic-data

// ## START 2.6.12-get-vehicle-status
- (void) getVehicleStatus:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *vin = params[@"route"][@"vin"];

        NSString *requestPath = [NSString stringWithFormat:@"remoteservices/v1/vehicle/status/view/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.6.12-get-vehicle-status

// ## START 2.16.1-add-a-vehicle
- (void) addAVehicle:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *requestPath = [NSString stringWithFormat:@"vehicles/v1/vehicle/add"];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"POST"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.16.1-add-a-vehicle

// ## START 2.16.4-view-a-vehicle
- (void) viewAVehicle:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    NSString *vin = params[@"route"][@"vin"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *requestPath = [NSString stringWithFormat:@"vehicles/v1/vehicle/view/%@", vin];
        NSURL *requestURL = [self buildURL:requestPath];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [request setHTTPMethod:@"GET"];

        ASDPResult *result = [self processRequest:request params:params[@"request"]];

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    });
}
// ## END 2.16.1-add-a-vehicle

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

- (ASDPResult *) processRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params
{
    if (![@"GET" isEqualToString:request.HTTPMethod])
    {
        if (params && params.count > 0)
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
            [request setHTTPBody:jsonData];
        } else
        {
            NSString *defaultBody = @"{}";
            NSData *defaultBodyData = [defaultBody dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:defaultBodyData];
        }
    }

    if (request.allHTTPHeaderFields.count == 0)
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        if (self.authToken) [request setValue:self.authToken forHTTPHeaderField:@"Authorization"];
        if (self.apiKey) [request setValue:self.apiKey forHTTPHeaderField:@"APIKey"];
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

- (void) executeAPI:(APISpec *)spec routeParams:(NSDictionary *)routeParams requestParams:(NSDictionary *)requestParams completion:(ASDPRequestCompletionBlock)completion
{
    SEL apiSelector = [APIManager selectorForAPISpec:spec];

    NSDictionary *params;

    if (routeParams && requestParams)
        params = @{ @"route" : routeParams, @"request" : requestParams };
    else if (routeParams)
        params = @{ @"route" : routeParams };
    else if (requestParams)
        params = @{ @"request" : requestParams };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:apiSelector withObject:params withObject:completion];
#pragma clang diagnostic pop
}

@end
