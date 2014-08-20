//
//  ASDPRequestManager.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/19/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASDPResult.h"

@interface ASDPRequestManager : NSObject

+ (ASDPRequestManager *) sharedManager;

- (ASDPResult *) login:(NSDictionary *)params;

@end
