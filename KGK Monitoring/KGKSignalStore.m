//
//  KGKSignalStore.m
//  KGK Monitoring
//
//  Created by Admin on 17/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKSignalStore.h"
#import "KGKDispatcher.h"
#import "Tolo.h"
#import "Action.h"
#import "ActionCreatorConstants.h"
#import "ActionCreator.h"
#import "SignalsFromDatabaseDelivery.h"

@implementation KGKSignalStore

static KGKSignalStore *instance = nil;

+ (KGKSignalStore *)getInstance:(KGKDispatcher *)dispatcher {
    if (instance == nil) {
        instance = [[KGKSignalStore alloc] init:dispatcher];
    }
    return instance;
}

- (instancetype)init:(KGKDispatcher *)dispatcher {
    self = [super init:dispatcher];
    REGISTER();
    
    return self;
}

SUBSCRIBE(Action) {
    if ([[event type] isEqualToString:UPDATE_LAST_SIGNAL]) {
        self.lastSignal = [[event data] objectForKey:KEY_SIGNAL];
        [self emitStoreChange];
    }
}

SUBSCRIBE(SignalsFromDatabaseDelivery) {
    self.signalsForHistory = event.signals;
    
    if (!event.byPeriod) {
        if ([self.signalsForHistory count] >= 1) {
            self.lastSignal = self.signalsForHistory[[self.signalsForHistory count] - 1];
        }
    }
    [self emitStoreChange];
}

@end
