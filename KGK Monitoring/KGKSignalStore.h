//
//  KGKSignalStore.h
//  KGK Monitoring
//
//  Created by Admin on 17/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGKStore.h"
#import "KGKSignal.h"

@interface KGKSignalStore : KGKStore

@property (nonatomic) KGKSignal *lastSignal;
@property (nonatomic) KGKSignal *signalForMap;
@property (nonatomic) NSArray *signalsForHistory;

+ (instancetype)getInstance:(KGKDispatcher *)dispatcher;

@end
