//
// Created by Jeremy White on 8/20/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASDPResult : NSObject

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, readonly) int statusCode;
@property (nonatomic, strong, readonly) NSString *message;
@property (nonatomic, strong, readonly) NSString *body;
@property (nonatomic, strong, readonly) id bodyData;
@property (nonatomic, readonly) BOOL isSuccess;

- (instancetype) initWithStatusCode:(int)statusCode;
- (instancetype) initWithMessage:(NSString *)message;
- (instancetype) initWithStatusCode:(int)statusCode body:(NSData *)bodyData;

@end
