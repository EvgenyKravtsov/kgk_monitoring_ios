//
//  ActionCreatorConstants.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionCreatorConstants : NSObject

FOUNDATION_EXPORT NSString *const AUTHENTICATION_REQUEST;
FOUNDATION_EXPORT NSString *const KEY_LOGIN;
FOUNDATION_EXPORT NSString *const KEY_PASSWORD;

FOUNDATION_EXPORT NSString *const DEVICE_LIST_RESPONSE;
FOUNDATION_EXPORT NSString *const KEY_DEVICES;

FOUNDATION_EXPORT NSString *const GET_LAST_SIGNAL_DATE_FROM_DATABASE;
FOUNDATION_EXPORT NSString *const REQUEST_LAST_SIGNALS_FROM_SERVER;
FOUNDATION_EXPORT NSString *const KEY_FROM_DATE;
FOUNDATION_EXPORT NSString *const KEY_TO_DATE;
FOUNDATION_EXPORT NSString *const KEY_SIGNAL;
FOUNDATION_EXPORT NSString *const UPDATE_LAST_SIGNAL;

FOUNDATION_EXPORT NSString *const QUERY_BEACON_REQUEST;

FOUNDATION_EXPORT NSString *const TOGGLE_SEARCH_MODE_REQUEST;
FOUNDATION_EXPORT NSString *const KEY_SEARCH_MODE_STATUS;

FOUNDATION_EXPORT NSString *const SEND_SETTINGS_REQUEST;
FOUNDATION_EXPORT NSString *const KEY_SETTINGS;

FOUNDATION_EXPORT NSString *const GET_SIGNALS_FROM_DATABASE;
FOUNDATION_EXPORT NSString *const KEY_NUMBER_OF_SIGNALS;
FOUNDATION_EXPORT NSString *const GET_SIGNALS_FROM_DATABASE_BY_PERIOD;

@end
