//
//  KGKHttpCommunication.m
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKHttpCommunication.h"
#import "Tolo.h"
#import "Action.h"
#import "ActionCreator.h"
#import "ActionCreatorConstants.h"
#import "KGKHttpConstants.h"
#import "KGKLoginEvent.h"
#import "AppDelegate.h"
#import "KGKSignal.h"
#import "DatabaseManager.h"
#import "LastActionDateStorage.h"
#import "ToggleSearchModeEvent.h"
#import "SettingsSentEvent.h"
#import "KGKDownloadDataInProgressEvent.h"

@interface KGKHttpCommunication ()

@property (nonatomic, copy) void(^successBlock)(NSData *);

@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) ActionCreator *actionCreator;

@end

@implementation KGKHttpCommunication

- (instancetype)init {
    self.dispatcher = [KGKDispatcher getInstance];
    self.actionCreator = [ActionCreator getInstance:self.dispatcher];
    REGISTER();
    return [super init];
}

- (void)retrieveURL:(NSURL *)url successBlock:(void(^)(NSData *))successBlock {
    self.successBlock = successBlock;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

- (void)retrieveURLwithJSON:(NSURL *)url json:(NSString *)json successBlock:(void(^)(NSData *))successBlock {
    self.successBlock = successBlock;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf
                                                          delegate:self
                                                     delegateQueue:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.successBlock(data);
    });
}

SUBSCRIBE(Action) {
    NSString *type = [event type];
    
    if ([type isEqualToString:AUTHENTICATION_REQUEST]) {
        NSString *login = [[event data] objectForKey:KEY_LOGIN];
        NSString *password = [[event data] objectForKey:KEY_PASSWORD];
        [self authenticationRequest:login:password];
    } else if ([type isEqualToString:REQUEST_LAST_SIGNALS_FROM_SERVER]) {
        NSInteger fromDate = [[[event data] objectForKey:KEY_FROM_DATE] integerValue];
        NSInteger toDate = [[[event data] objectForKey:KEY_TO_DATE] integerValue];
        [self lastSignalsRequest:fromDate toDate:toDate];
    } else if ([type isEqualToString:QUERY_BEACON_REQUEST]) {
        [self queryBeaconRequest];
    } else if ([type isEqualToString:TOGGLE_SEARCH_MODE_REQUEST]) {
        BOOL mode = [[[event data] objectForKey:KEY_SEARCH_MODE_STATUS] boolValue];
        [self toggleSearchModeRequest:mode];
    } else if ([type isEqualToString:SEND_SETTINGS_REQUEST]) {
        NSString *json = [[event data] objectForKey:KEY_SETTINGS];
        [self sendSettingsRequest:json];
    }
}

- (void)authenticationRequest:(NSString *)login :(NSString *)password {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:AUTHENTICATION_URL];
    [urlString appendString:@"?"];
    [urlString appendString:@"login="];
    [urlString appendString:login];
    [urlString appendString:@"&"];
    [urlString appendString:@"password="];
    [urlString appendString:password];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self retrieveURL:url
         successBlock:^(NSData *response) {
             NSError *error = nil;
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:0
                                                                    error:&error];
             
             KGKLoginEvent *loginEvent = [[KGKLoginEvent alloc] init];
             NSInteger status = [[data objectForKey:@"status"] integerValue];
             if (!error) {
                 if (status == 1) {
                     [self deviceListRequest];
                 } else {
                     loginEvent.type = LOGIN_FAILED;
                     PUBLISH(loginEvent);
                 }
             } else {
                 loginEvent.type = LOGIN_ERROR;
                 PUBLISH(loginEvent);
             }
         }];
}

- (void)deviceListRequest {
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:DEVICE_LIST_URL];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self retrieveURL:url
         successBlock:^(NSData *response) {
             NSError *error = nil;
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:0
                                                                    error:&error];
             
             KGKLoginEvent *loginEvent = [[KGKLoginEvent alloc] init];
             NSInteger status = [[data objectForKey:@"status"] integerValue];
             if (!error) {
                 if (status == 1) {
                     [self.actionCreator receiveDeviceListResponse:data[@"data"]];
                     loginEvent.type = LOGIN_SUCCESS;
                     PUBLISH(loginEvent);
                 } else {
                     loginEvent.type = LOGIN_NO_DEVICES;
                     PUBLISH(loginEvent);
                 }
             } else {
                 loginEvent.type = LOGIN_ERROR;
                 PUBLISH(loginEvent);
             }
         }];
}

- (void)lastSignalsRequest:(NSInteger)fromDate toDate:(NSInteger)toDate {
    KGKDownloadDataInProgressEvent *event = [[KGKDownloadDataInProgressEvent alloc] init];
    event.status = STARTED;
    PUBLISH(event);
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:GET_LAST_SIGNALS_URL];
    [urlString appendString:@"?"];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    [urlString appendString:[[NSString alloc] initWithFormat:@"device=%@&", deviceId]];
    [urlString appendFormat:@"from=%ld&", (long)fromDate];
    [urlString appendFormat:@"to=%ld", (long)toDate];
    
    NSURL *url = [NSURL URLWithString:urlString];
    [self retrieveURL:url
         successBlock:^(NSData *response) {
             NSError *error = nil;
             NSDictionary *rawData = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:0
                                                                    error:&error];
             
             for (NSDictionary *data in rawData[@"data"]) {
                 NSDictionary *rawData = data[@"params_json"];
                 NSString *rawDataString = [[NSString alloc] initWithFormat:@"%@", rawData];
                 NSData *paramsData = [rawDataString dataUsingEncoding:NSUTF8StringEncoding];
                 NSDictionary *rawDataDict = [NSJSONSerialization JSONObjectWithData:paramsData
                                                                                 options:0
                                                                                   error:nil];
                 NSDictionary *params = rawDataDict[@"0"];
                 if ([params count] > 0) {
                     KGKSignal *signal = [[KGKSignal alloc] initWithData:data params:params];
                     [self.actionCreator insertSignalToPersistanceStorage:signal];
                 } else {
                     NSLog(@"Signal with no data");
                 }
             }
             
             KGKDownloadDataInProgressEvent *event = [[KGKDownloadDataInProgressEvent alloc] init];
             event.status = SUCCESS;
             PUBLISH(event);
         }];
}

- (void)queryBeaconRequest {
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    [[LastActionDateStorage getInstance] save:now];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@?device=%@", QUERY_BEACON_URL, deviceId];
    NSURL *url = [NSURL URLWithString:urlString];
    [self retrieveURL:url
         successBlock:^(NSData *response) {
             NSError *error = nil;
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:0
                                                                    error:&error];
             NSLog(@"%@", data);
         }];		
}

- (void)toggleSearchModeRequest:(BOOL)mode {
    NSInteger now = [[NSDate date] timeIntervalSince1970];
    [[LastActionDateStorage getInstance] save:now];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@?device=%@&search=%@", TOGGLE_SEARCH_MODE_REQUEST_URL, deviceId, [NSNumber numberWithBool:mode]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    [self retrieveURL:url
         successBlock:^(NSData *response) {
             NSError *error = nil;
             NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:0
                                                                    error:&error];
             NSLog(@"%@", data);
             ToggleSearchModeEvent *event = [[ToggleSearchModeEvent alloc] init];
             
             if ([data[@"status"] integerValue] == 1) {
                 event.searchModeState = YES;
             } else {
                 event.searchModeState = NO;
             }
             PUBLISH(event);
         }];
}

- (void)sendSettingsRequest:(NSString *)json {
    NSURL *url = [NSURL URLWithString:SETTINGS_REQUEST_URL];
    [self retrieveURLwithJSON:url json:json successBlock:^(NSData *response) {
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response
                                                             options:0
                                                               error:&error];
        SettingsSentEvent *event = [[SettingsSentEvent alloc] init];
        NSInteger status = [data[@"status"] integerValue];
        event.status = status;
        PUBLISH(event);
    }];
}

@end


































