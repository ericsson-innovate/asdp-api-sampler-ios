//
// Created by Jeremy White on 8/18/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONObjectCoding.h"

#define kAPICategoryNames @{ \
                               @"know-driver" : @"Know Driver", \
                               @"know-car" : @"Know Car", \
                               @"control-car" : @"Control Car" \
                           }

@interface APICategory : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *specs;

@end
