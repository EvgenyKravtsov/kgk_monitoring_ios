//
//  KGKDispatcher.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKDispatcher.h"
#import "Tolo.h"
#import "ActionBuilder.h"

@interface KGKDispatcher ()

@property (nonatomic) Tolo *bus;

@end

@implementation KGKDispatcher

static KGKDispatcher *instance = nil;

+ (KGKDispatcher *)getInstance {
    if (instance == nil) {
        instance = [[KGKDispatcher alloc] init];
    }
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _bus = Tolo.sharedInstance;
    }
    return self;
}

- (void)dispatch:(NSString *)type :(NSArray *)data {
    if ([self isEmpty:type]) {
        NSLog(@"Type must not be empty");
    }
    
    if ([data count] % 2 != 0) {
        NSLog(@"Data must be a valid key/value pairs");
    }
    
    ActionBuilder *actionBuilder = [Action type:type];
    int i = 0;
    while (i < [data count]) {
        NSString *key = data[i++];
        id value = data[i++];
        [actionBuilder bundle:key :value];
    }
    
    [self post:[actionBuilder build]];
}

- (void)emitChange:(KGKStoreChangeEvent *)event {
    [self post:event];
}

- (void)post:(id)event {
    PUBLISH(event);
}

- (BOOL)isEmpty:(NSString *)type {
    return type == nil || [type length] == 0;
}

@end
