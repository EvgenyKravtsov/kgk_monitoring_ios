//
//  ActionCreatorConstants.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "ActionCreatorConstants.h"

@implementation ActionCreatorConstants

NSString *const AUTHENTICATION_REQUEST = @"authentication_request";
NSString *const KEY_LOGIN = @"key_login";
NSString *const KEY_PASSWORD = @"key_password";

NSString *const DEVICE_LIST_RESPONSE = @"device_list_response";
NSString *const KEY_DEVICES = @"key_devices";

NSString *const GET_LAST_SIGNAL_DATE_FROM_DATABASE = @"get_last_signal_date_from_database";
NSString *const REQUEST_LAST_SIGNALS_FROM_SERVER = @"request_last_signals_from_server";
NSString *const KEY_FROM_DATE = @"key_from_date";
NSString *const KEY_TO_DATE = @"key_to_date";
NSString *const KEY_SIGNAL = @"key_signal";
NSString *const UPDATE_LAST_SIGNAL = @"update_last_signal";

NSString *const QUERY_BEACON_REQUEST = @"query_beacon_request";

NSString *const TOGGLE_SEARCH_MODE_REQUEST = @"toggle_search_mode_request";
NSString *const KEY_SEARCH_MODE_STATUS = @"key_search_mode_status";

NSString *const SEND_SETTINGS_REQUEST = @"send_settings_request";
NSString *const KEY_SETTINGS = @"key_settings";

NSString *const GET_SIGNALS_FROM_DATABASE = @"get_signals_from_database";
NSString *const KEY_NUMBER_OF_SIGNALS = @"key_number_of_signals";

NSString *const GET_SIGNALS_FROM_DATABASE_BY_PERIOD = @"get_signals_from_database_by_period";

@end
