//
//  KGKStore.h
//  KGK Monitoring
//
//  Created by Admin on 12/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGKDispatcher.h"

@interface KGKStore : NSObject

- (instancetype)init:(KGKDispatcher *)dispatcher;

- (void)emitStoreChange;

@end
