//
//  Action.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ActionBuilder;

@interface Action : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic) NSMutableDictionary *data;

- (id)init:(NSString *)type :(NSMutableDictionary *)data;

+ (ActionBuilder *)type:(NSString *)type;

@end
