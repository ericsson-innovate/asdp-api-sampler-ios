//
//  APISpec.h
//  ASDP Sampler
//
//  Created by Jeremy White on 8/18/14.
//  Copyright (c) 2014 AT&T Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONObjectCoding.h"

@class ResourceTable, Parameters;

@interface APISpecRaw : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *docNumber;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) Parameters *parameters; // array of RequestParams
@property (nonatomic, strong) ResourceTable *resourceTable;

@end

@interface ResourceTable : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSString *route;
@property (nonatomic, strong) NSArray *verbs;

@end

@interface Parameters : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSArray *requestBody;

@end

@interface RequestParam : NSObject <JSONObjectCoding>

@property (nonatomic, strong) NSString *desc;
@property (nonatomic) BOOL required;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *key;

@end
