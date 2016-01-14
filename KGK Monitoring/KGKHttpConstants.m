//
//  KGKHttpConstants.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKHttpConstants.h"

@implementation KGKHttpConstants

NSString *const AUTHENTICATION_URL = @"http://dev.trezub.ru/api2/beacon/authorize";
NSString *const LOGIN_SUCCESS = @"success";
NSString *const LOGIN_FAILED = @"failed";
NSString *const LOGIN_ERROR = @"error";
NSString *const LOGIN_NO_DEVICES = @"no_devices";

NSString *const DEVICE_LIST_URL = @"http://dev.trezub.ru/api2/beacon/getdeviceslist";

NSString *const GET_LAST_SIGNALS_URL = @"http://dev.trezub.ru/api2/beacon/getpackets";
NSString *const INSERT_SIGNAL_TO_PERSISTANCE_STORAGE = @"insert_signal_to_persistance_storage";

NSString *const QUERY_BEACON_URL = @"http://dev.trezub.ru/api2/beacon/cmdrequestinfo";

NSString *const TOGGLE_SEARCH_MODE_REQUEST_URL = @"http://dev.trezub.ru/api2/beacon/cmdtogglefind";

NSString *const SETTINGS_REQUEST_URL = @"http://dev.trezub.ru/api2/beacon/cmdsetsettings";

NSString *const STARTED = @"started";
NSString *const SUCCESS = @"success";
NSString *const ERROR = @"error";

@end
