//
//  KGKDeviceStore.m
//  KGK Monitoring
//
//  Created by Admin on 12/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKDeviceStore.h"
#import "KGKDispatcher.h"
#import "Tolo.h"
#import "Action.h"
#import "ActionCreatorConstants.h"
#import "KGKDevice.h"

@implementation KGKDeviceStore

static KGKDeviceStore *instance = nil;

+ (KGKDeviceStore *)getInstance:(KGKDispatcher *)dispatcher {
    if (instance == nil) {
        instance = [[KGKDeviceStore alloc] init:dispatcher];
    }
    return instance;
}

- (instancetype)init:(KGKDispatcher *)dispatcher {
    REGISTER();
    self.devices = [[NSMutableArray alloc] init];
    return [super init:dispatcher];
}

SUBSCRIBE(Action) {
    if ([event.type isEqualToString:DEVICE_LIST_RESPONSE]) {
        NSDictionary *rawData = [event.data objectForKey:KEY_DEVICES];
        
        [self.devices removeAllObjects];
        for (NSDictionary *object in rawData) {
            KGKDevice *device = [[KGKDevice alloc] init];
            device.id = object[@"id"];
            device.model = object[@"model"];
            
            [self.devices addObject:device];
        }
    }
}

@end
