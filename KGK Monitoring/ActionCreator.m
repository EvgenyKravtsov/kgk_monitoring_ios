//
//  ActionCreator.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "ActionCreator.h"
#import "KGKDispatcher.h"
#import "ActionCreatorConstants.h"
#import "KGKHttpConstants.h"

@interface ActionCreator ()

@property (nonatomic) KGKDispatcher *dispatcher;

@end

@implementation ActionCreator

static ActionCreator *instance = nil;

- (instancetype)init:(KGKDispatcher *)dispatcher {
    self.dispatcher = dispatcher;
    return self;
}

+ (instancetype)getInstance:(KGKDispatcher *)dispatcher {
    if (instance == nil) {
        instance = [[ActionCreator alloc] init:dispatcher];
    }
    return instance;
}

- (void)sendAuthenticationRequest:(NSString *)login :(NSString *)password {
    NSArray *data = @[KEY_LOGIN, login, KEY_PASSWORD, password];
    [self.dispatcher dispatch:AUTHENTICATION_REQUEST
                             :data];
}

- (void)receiveDeviceListResponse:(NSDictionary *)devicesData {
    NSArray *data = @[KEY_DEVICES, devicesData];
    [self.dispatcher dispatch:DEVICE_LIST_RESPONSE
                             :data];
}

- (void)getLastSignalDateFromDatabase {
    [self.dispatcher dispatch:GET_LAST_SIGNAL_DATE_FROM_DATABASE :nil];
}

- (void)requestLastSignalsFromServer:(NSInteger)lastSingaldate currentDate:(NSInteger)currentDate {
    NSNumber *lastSignalDateNumber = [NSNumber numberWithInteger:lastSingaldate];
    NSNumber *currentDateNumber = [NSNumber numberWithInteger:currentDate];
    NSArray *data = @[KEY_FROM_DATE, lastSignalDateNumber, KEY_TO_DATE, currentDateNumber];
    [self.dispatcher dispatch:REQUEST_LAST_SIGNALS_FROM_SERVER
                             :data];
}

- (void)insertSignalToPersistanceStorage:(KGKSignal *)signal {
    NSArray *data = @[KEY_SIGNAL, signal];
    [self.dispatcher dispatch:INSERT_SIGNAL_TO_PERSISTANCE_STORAGE
                             :data];
}

- (void)updateLastSignal:(KGKSignal *)signal {
    NSArray *data = @[KEY_SIGNAL, signal];
    [self.dispatcher dispatch:UPDATE_LAST_SIGNAL
                             :data];
}

- (void)sendQueryBeaconRequest {
    [self.dispatcher dispatch:QUERY_BEACON_REQUEST
                             :nil];
}

- (void)sendToggleSearchModeRequest:(BOOL)flag {
    NSArray *data = @[KEY_SEARCH_MODE_STATUS, [NSNumber numberWithBool:flag]];
    [self.dispatcher dispatch:TOGGLE_SEARCH_MODE_REQUEST
                             :data];
}

- (void)sendSettingsRequest:(NSString *)json {
    NSArray *data = @[KEY_SETTINGS, json];
    [self.dispatcher dispatch:SEND_SETTINGS_REQUEST
                             :data];
}

- (void)getSignalsFromDatabase:(NSInteger)count {
    NSArray *data = @[KEY_NUMBER_OF_SIGNALS, [NSNumber numberWithInteger:count]];
    [self.dispatcher dispatch:GET_SIGNALS_FROM_DATABASE
                             :data];
}

- (void)getSignalsFromDatabaseByPeriod:(NSInteger)fromDate toDate:(NSInteger)toDate {
    NSArray *data = @[KEY_FROM_DATE, [NSNumber numberWithInteger:fromDate], KEY_TO_DATE, [NSNumber numberWithInteger:toDate]];
    [self.dispatcher dispatch:GET_SIGNALS_FROM_DATABASE_BY_PERIOD
                             :data];
}

@end













