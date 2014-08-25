//
//  ASDPRequestManager.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/19/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASDPResult.h"
#import "APISpec.h"

@interface ASDPRequestManager : NSObject

typedef void (^ ASDPRequestCompletionBlock)(ASDPResult *result);

+ (ASDPRequestManager *) sharedManager;

@property (nonatomic, strong, readonly) NSString *vin;
@property (nonatomic, strong, readonly) NSString *authToken;
@property (nonatomic, strong, readonly) NSString *apiKey;

- (void) executeAPI:(APISpec *)spec params:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;

// START 2.6.x APIs
- (void) signUp:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) validateOneTimePassword:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) setPIN:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) login:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) doorUnlock:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) doorLock:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) engineOn:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) engineOff:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) honkAndBlink:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) checkRequestStatus:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) viewDiagnosticData:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
- (void) getVehicleStatus:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
// END 2.6.x APIs

// START 2.16.x APIs
- (void) addAVehicle:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;


- (void) viewAVehicle:(NSDictionary *)params completion:(ASDPRequestCompletionBlock)completion;
// END 2.16.x APIs

- (void) logout;

@end
