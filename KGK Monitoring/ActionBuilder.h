//
//  ActionBuilder.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@interface ActionBuilder : NSObject

- (instancetype)bundle:(NSString *)key :(id)value;
- (Action *)build;
- (instancetype)with:(NSString *)type;

@end
