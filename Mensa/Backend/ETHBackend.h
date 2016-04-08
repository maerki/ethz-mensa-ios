//
//  ETHBackend.h
//  Campus
//
//  Created by Nicolas Märki on 13.08.12.
//  Copyright (c) 2012 Nicolas Märki. All rights reserved.
//

#define kETHConfigUpdated @"kETHConfigUpdated"
#define kETHConfigUpdatError @"kETHConfigUpdateError"

#define kETHLoginURL @"BACKEND_API_PATH"

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface ETHBackend : NSObject

+ (void)loadImage:(NSString *)imageUrl complete:(void (^)(UIImage *image, NSError *error))aHandler;
+ (void)loadAction:(NSString *)action complete:(void (^)(id result, NSError *error))aHandler;
+ (void)loadAction:(NSString *)action
            params:(NSDictionary *)params
          complete:(void (^)(id result, NSError *error))handler;
+ (void)loadAction:(NSString *)action
            params:(NSDictionary *)params
            method:(NSString *)method
          complete:(void (^)(id result, NSError *error))handler;
+ (void)loadNethzAuth:(void (^)(NSURLRequest *redirect, id result, NSError *error))handler;

+ (NSString *)loginName;
+ (NSString *)loginMail;
+ (NSString *)loginHash;

+ (void)uploadAction:(NSString *)action
              params:(NSDictionary *)params
                data:(NSData *)data
            complete:(void (^)(id result, NSError *error))handler;

+ (void)sendLog;

@end
