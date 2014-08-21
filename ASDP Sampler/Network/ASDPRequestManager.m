//
//  ASDPRequestManager.m
//  ASDP Sampler
//
//  Created by Jeremy White on 8/19/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "ASDPRequestManager.h"

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

+ (NSString *) baseURL
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"baseURL"];
}

// ## START 2.6.4-login
- (void) login:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        ASDPResult *result;

        NSString *username = params[@"username"];
        NSString *pin = params[@"pin"];
        NSString *vin = params[@"vin"];

        if (username && pin && vin)
        {
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
        } else
        {
            result = [[ASDPResult alloc] initWithStatusCode:400];
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

- (NSURL *) buildURL:(NSString *)targetPath
{
    NSString *targetURL = [NSString stringWithString:[ASDPRequestManager baseURL]];
    targetURL = [targetURL stringByAppendingPathComponent:targetPath];

    return [NSURL URLWithString:targetURL];
}

@end
