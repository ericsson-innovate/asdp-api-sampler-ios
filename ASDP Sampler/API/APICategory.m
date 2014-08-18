//
// Created by Jeremy White on 8/18/14.
// Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import "APICategory.h"
#import "APISpec.h"


@implementation APICategory

+ (id) fromJSONObject:(NSDictionary *)json
{
    // we don't need to implement this method
    return nil;
}

- (id) toJSONObject
{
    NSMutableArray *specs = [NSMutableArray new];

    [self.specs enumerateObjectsUsingBlock:^(APISpec *spec, NSUInteger idx, BOOL *stop) {
        [specs addObject:[spec toJSONObject]];
    }];

    return @{
            @"name" : self.name,
            @"specs" : specs
    };
}

- (NSString *) description
{
    id json = [self toJSONObject];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
