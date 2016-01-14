//
//  KGKDeviceStore.h
//  KGK Monitoring
//
//  Created by Admin on 12/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGKStore.h"

@interface KGKDeviceStore : KGKStore

@property (nonatomic) NSMutableArray *devices;

+ (instancetype)getInstance:(KGKDispatcher *)dispatcher;

@end
