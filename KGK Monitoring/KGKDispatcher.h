//
//  KGKDispatcher.h
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGKStoreChangeEvent.h"


@interface KGKDispatcher : NSObject

+ (KGKDispatcher *)getInstance;
- (void)dispatch:(NSString *)type :(NSArray *)data;
- (void)emitChange:(KGKStoreChangeEvent *)event;

@end
