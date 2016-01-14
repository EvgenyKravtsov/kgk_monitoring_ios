//
//  Action.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "Action.h"
#import "ActionBuilder.h"

@interface Action ()

@end

@implementation Action

- (id)init:(NSString *)type :(NSMutableDictionary *)data {
    self.type = type;
    self.data = data;
    return self;
}

+ (ActionBuilder *)type:(NSString *)type {
    ActionBuilder *actionBuilder = [[ActionBuilder alloc] init];
    return [actionBuilder with:type];
}

@end
