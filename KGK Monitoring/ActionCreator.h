//
//  ActionCreator.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGKDispatcher.h"
#import "KGKSignal.h"

@interface ActionCreator : NSObject

+ (instancetype)getInstance:(KGKDispatcher *)dispatcher;
- (void)sendAuthenticationRequest:(NSString *)login :(NSString *)password;
- (void)receiveDeviceListResponse:(NSDictionary *)devicesData;
- (void)getLastSignalDateFromDatabase;
- (void)requestLastSignalsFromServer:(NSInteger)lastSingaldate currentDate:(NSInteger)currentDate;
- (void)insertSignalToPersistanceStorage:(KGKSignal *)signal;
- (void)updateLastSignal:(KGKSignal *)signal;
- (void)sendQueryBeaconRequest;
- (void)sendToggleSearchModeRequest:(BOOL)flag;
- (void)sendSettingsRequest:(NSString *)json;
- (void)getSignalsFromDatabase:(NSInteger)count;
- (void)getSignalsFromDatabaseByPeriod:(NSInteger)fromDate toDate:(NSInteger)toDate;

@end
