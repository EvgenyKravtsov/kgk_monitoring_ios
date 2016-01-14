//
//  KGKStore.m
//  KGK Monitoring
//
//  Created by Admin on 12/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKStore.h"
#import "KGKDispatcher.h"
#import "KGKStoreChangeEvent.h"

@interface KGKStore ()

@property (nonatomic) KGKDispatcher *dispatcher;

@end

@implementation KGKStore

- (instancetype)init:(KGKDispatcher *)dispatcher {
    self.dispatcher = dispatcher;
    return [super init];
}

- (void)emitStoreChange {
    [self.dispatcher emitChange:[[KGKStoreChangeEvent alloc] init]];
}

@end
