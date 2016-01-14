//
//  AppDelegate.m
//  KGK Monitoring
//
//  Created by Admin on 05/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "AppDelegate.h"
#import "KGKLoginScreenViewController.h"
#import "KGKHttpCommunication.h"
#import "KGKDeviceStore.h"
#import "KGKSignalStore.h"
#import "KGKDispatcher.h"
#import "DatabaseManager.h"
@import GoogleMaps;

@interface AppDelegate ()

@property (nonatomic) KGKHttpCommunication *httpCommunication;
@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) KGKDeviceStore *deviceStore;
@property (nonatomic) KGKSignalStore *signalStore;
@property (nonatomic) DatabaseManager *databaseManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [GMSServices provideAPIKey:@"AIzaSyAaj46H_sHb_ed1B_OT6NtEJ9jM3949m4Q"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    KGKLoginScreenViewController *loginScreenViewController =
    [[KGKLoginScreenViewController alloc] init];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController: loginScreenViewController];
    self.window.rootViewController = navigationController;
    
    DatabaseManager *databaseManager = [DatabaseManager getInstance];
    self.databaseManager = databaseManager;
    KGKHttpCommunication *httpCommunication = [[KGKHttpCommunication alloc] init];
    self.httpCommunication = httpCommunication;
    KGKDispatcher *dispatcher = [KGKDispatcher getInstance];
    self.dispatcher = dispatcher;
    KGKDeviceStore *deviceStore = [KGKDeviceStore getInstance:self.dispatcher];
    self.deviceStore = deviceStore;
    KGKSignalStore *signalStore = [KGKSignalStore getInstance:self.dispatcher];
    self.signalStore = signalStore;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (void)saveStringToUserDefaults:(NSString *)key value:(NSString *)value {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:value forKey:key];
    [preferences synchronize];
}

+ (NSString *)loadStringFromUserDefaults:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:key] != nil) {
        return [preferences stringForKey:key];
    } else {
        return nil;
    }
}

+ (void)saveBooleanToUserDefaults:(NSString *)key value:(BOOL)value {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setBool:value forKey:key];
    [preferences synchronize];
}

+ (BOOL)loadBooleanFromUserDefaults:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:key] != nil) {
        return [preferences boolForKey:key];
    } else {
        return false;
    }
}

+ (void)saveIntegerToUserDefaults:(NSString *)key value:(NSInteger)value {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setInteger:value forKey:key];
    [preferences synchronize];
}

+ (NSInteger)loadIntegerFromUserDefaults:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences objectForKey:key] != nil) {
        return [[preferences objectForKey:key] integerValue];
    } else {
        return 0;
    }
}

+ (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd    HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedString = [formatter stringFromDate:date];
    return formattedString;
}

+ (NSString *)formatTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *formattedString = [formatter stringFromDate:date];
    return formattedString;
}

@end













