//
//  ActionBuilder.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "ActionBuilder.h"

@interface ActionBuilder ()

@property (nonatomic, copy) NSString *type;
@property (nonatomic) NSMutableDictionary *data;

@end

@implementation ActionBuilder

- (instancetype)bundle:(NSString *)key :(id)value {
    if (key == nil) {
        NSLog(@"Key may not be null");
    }
    
    if (value == nil) {
        NSLog(@"Value may not be null");
    }
    
    [self.data setValue:value forKey:key];
    return self;
}

- (Action *)build {
    if (self.type == nil || [self.type length] == 0) {
        NSLog(@"At least one key is required");
    }
    return [[Action alloc] init:self.type:self.data];
}

- (instancetype)with:(NSString *)type {
    if (type == nil) {
        NSLog(@"Type may not be null");
    }
    
    self.type = type;
    self.data = [[NSMutableDictionary alloc] init];
    
    return self;
}

@end
