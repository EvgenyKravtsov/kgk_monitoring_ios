//
//  AppDelegate.h
//  KGK Monitoring
//
//  Created by Admin on 05/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSInteger activeDeviceId;

+ (void)saveStringToUserDefaults:(NSString *)key value:(NSString *)value;
+ (NSString *)loadStringFromUserDefaults:(NSString *)key;
+ (void)saveBooleanToUserDefaults:(NSString *)key value:(BOOL)value;
+ (BOOL)loadBooleanFromUserDefaults:(NSString *)key;
+ (void)saveIntegerToUserDefaults:(NSString *)key value:(NSInteger)value;
+ (NSInteger)loadIntegerFromUserDefaults:(NSString *)key;
+ (NSString *)formatDate:(NSDate *)date;
+ (NSString *)formatTime:(NSDate *)date;

@end

