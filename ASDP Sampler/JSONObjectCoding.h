//
//  JSONCoding.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONObjectCoding <NSObject>

@required
+ (id) fromJSONObject:(NSDictionary *)json;
- (id) toJSONObject;

@end
