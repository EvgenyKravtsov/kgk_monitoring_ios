//
//  LastActionDateStorage.h
//  KGK Monitoring
//
//  Created by Admin on 17/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastActionDateStorage : NSObject

+ (instancetype)getInstance;

- (void)save:(NSInteger)date;

- (NSInteger)load;

@end
