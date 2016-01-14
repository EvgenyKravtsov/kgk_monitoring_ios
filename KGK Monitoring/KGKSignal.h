//
//  KGKSignal.h
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGKSignal : NSObject

@property (nonatomic) NSInteger deviceId;
@property (nonatomic) NSInteger mode;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) NSInteger date; // Unix seconds
@property (nonatomic) double voltage; // Volts
@property (nonatomic) double balance; // Russian roubles
@property (nonatomic) NSInteger satellites;
@property (nonatomic) NSInteger charge; // Percentage
@property (nonatomic) NSInteger speed; // km/h
@property (nonatomic) NSInteger direction;
@property (nonatomic) NSInteger temperature; // Celsius

- (instancetype)initWithData:(NSDictionary *)mainData params:(NSDictionary *)params;

@end
