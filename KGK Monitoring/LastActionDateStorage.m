//
//  LastActionDateStorage.m
//  KGK Monitoring
//
//  Created by Admin on 17/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "LastActionDateStorage.h"
#import "AppDelegate.h"
#import "UtilityConstants.h"

@implementation LastActionDateStorage

static LastActionDateStorage *instance = nil;

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[LastActionDateStorage alloc] init];
    }
    return instance;
}

- (void)save:(NSInteger)date {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSInteger deviceId = appDelegate.activeDeviceId;
    [AppDelegate saveIntegerToUserDefaults:[[NSString alloc] initWithFormat:@"%@%ld", KEY_LAST_ACTION_DATE, (long)deviceId]
                                     value:date];
}

- (NSInteger)load {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSInteger deviceId = appDelegate.activeDeviceId;
    return [AppDelegate loadIntegerFromUserDefaults:[[NSString alloc] initWithFormat:@"%@%ld", KEY_LAST_ACTION_DATE, (long)deviceId]];
}

@end
