//
//  KGKSignal.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKSignal.h"
#import "AppDelegate.h"

@interface KGKSignal ()

@end

@implementation KGKSignal

- (instancetype)initWithData:(NSDictionary *)mainData params:(NSDictionary *)params {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.deviceId = appDelegate.activeDeviceId;
    self.mode = 0;
    self.latitude = [mainData[@"lat"] doubleValue];
    self.longitude = [mainData[@"lng"] doubleValue];
    self.date = [mainData[@"packet_date"] integerValue];
    self.voltage = [params[@"BAT"] integerValue] / 100.0;
    self.balance = [params[@"SIM_BALANCE"] integerValue] / 1000;
    self.satellites = [mainData[@"sat"] integerValue];
    self.charge = [params[@"BAT"] integerValue] < 200 ? 0 : [params[@"BAT"] integerValue] - 200;
    self.speed = [mainData[@"speed"] integerValue];
    self.direction = [mainData[@"az"] integerValue];
    self.temperature = [params[@"TEMP"] integerValue];
    
    return self;
}

- (NSString *)description {
    return [[NSString alloc] initWithFormat:@"%ld %ld %f %f %ld %f %f %ld %ld %ld %ld %ld", (long)self.deviceId, (long)self.mode, self.latitude, self.longitude, (long)self.date, self.voltage, self.balance, (long)self.satellites, (long)self.charge, (long)self.speed, (long)self.direction, (long)self.temperature];
}

@end
