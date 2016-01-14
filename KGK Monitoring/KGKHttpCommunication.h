//
//  KGKHttpCommunication.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KGKHttpCommunication : NSObject<NSURLSessionDownloadDelegate>

- (void)retrieveURL:(NSURL *)url successBlock:(void(^)(NSData *))successBlock;

@end
