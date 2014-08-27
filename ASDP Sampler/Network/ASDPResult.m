//
// Created by Jeremy White on 8/20/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "ASDPResult.h"


@implementation ASDPResult
{
    NSString *_message;
}

- (instancetype) initWithStatusCode:(int)statusCode
{
    self = [super init];

    if (self)
    {
        _statusCode = statusCode;
    }

    return self;
}

- (instancetype) initWithMessage:(NSString *)message
{
    self = [super init];

    if (self)
    {
        _message = message;
    }

    return self;
}

- (instancetype) initWithStatusCode:(int)statusCode body:(NSData *)bodyData
{
    self = [super init];

    if (self)
    {
        _statusCode = statusCode;
        _bodyData = bodyData;

        if (_bodyData && _bodyData.length > 0)
        {
            _body = [[NSString alloc] initWithData:_bodyData encoding:NSUTF8StringEncoding];

            NSError *error;
            _data = [NSJSONSerialization JSONObjectWithData:_bodyData options:0 error:&error];

            if (error || !_data)
                _message = @"API request failed: invalid JSON data";
        }
    }

    return self;
}

- (NSString *) message
{
    if (_message && !_message.length > 0)
        return _message;

    if (self.isSuccess)
        return @"API request succeeded";
    else
        return @"API request failed";
}

- (BOOL) isSuccess
{
    return self.statusCode >= 200 && self.statusCode < 300;
}

@end
