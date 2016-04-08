//
//  ETHBackend.m
//  Campus
//
//  Created by Nicolas Märki on 13.08.12.
//  Copyright (c) 2012 Nicolas Märki. All rights reserved.
//

#import "ETHBackend.h"

//#import "GAI.h"

#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

//  #define DEBUG_NETWORK

@interface ETHBackend () {
}

@end

@implementation ETHBackend

+ (void)initialize
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    NSURLCache *URLCache =
        [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

+ (void)loadImage:(NSString *)imageUrl complete:(void (^)(UIImage *image, NSError *error))aHandler
{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]
                                             cachePolicy:NSURLCacheStorageAllowed
                                         timeoutInterval:10];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFImageResponseSerializer serializer];
    op.securityPolicy.allowInvalidCertificates = YES;

    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                                      { aHandler(responseObject, nil); }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
                { aHandler(nil, error); }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

+ (void)loadAction:(NSString *)action complete:(void (^)(id, NSError *))handler
{
    [self loadAction:action params:nil complete:handler];
}

+ (void)loadAction:(NSString *)action
            params:(NSDictionary *)params
          complete:(void (^)(id result, NSError *error))handler
{
    [self loadAction:action params:params method:@"GET" complete:handler];
}

+ (void)loadAction:(NSString *)action
            params:(NSDictionary *)params
            method:(NSString *)method
          complete:(void (^)(id result, NSError *error))handler
{

    NSMutableDictionary *mutableParams = [params mutableCopy];
    if(!mutableParams)
    {
        mutableParams = [NSMutableDictionary dictionary];
    }

    mutableParams[@"action"] = action;

    NSMutableURLRequest *request =
        [[[AFHTTPRequestSerializer serializer] requestWithMethod:method
                                                       URLString:@"BACKEND_API_PATH"
                                                      parameters:mutableParams] mutableCopy];
    [self setRequestHeaders:request];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.readingOptions =
        NSJSONReadingAllowFragments | NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
    op.responseSerializer = serializer;
    op.securityPolicy.allowInvalidCertificates = YES;

    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                                      { handler(responseObject, nil); }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
                {
            NSLog(@"Error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            handler(nil, error);
        }];
    [[NSOperationQueue mainQueue] addOperation:op];

#ifdef DEBUG_NETWORK
    NSLog(@"Network: Started loading %@", url);
#endif
}

+ (void)loadNethzAuth:(void (^)(NSURLRequest *redirect, id result, NSError *error))handler
{

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]
        initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"BACKEND_API_PATH"]]];
    [op setRedirectResponseBlock:^NSURLRequest *
                                 (NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse)
                                 {
        if(redirectResponse)
        {
            dispatch_async(dispatch_get_main_queue(), ^
                                                      { handler(request, nil, nil); });
        }

        return request;
    }];

    op.responseSerializer = [AFJSONResponseSerializer serializer];

    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                                      { handler(nil, responseObject, nil); }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
                { handler(nil, nil, error); }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

+ (NSString *)loginHash
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"][@"hash"];
}
+ (NSString *)loginMail
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"][@"mail"];
}
+ (NSString *)loginName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"login"][@"name"];
}

+ (void)uploadAction:(NSString *)action
              params:(NSDictionary *)params
                data:(NSData *)data
            complete:(void (^)(id result, NSError *error))handler
{

    NSMutableDictionary *mutableParams = [params mutableCopy];
    if(!mutableParams)
    {
        mutableParams = [NSMutableDictionary dictionary];
    }

    mutableParams[@"action"] = action;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"picture"] URLByAppendingPathExtension:@"jpg"];

    [data writeToURL:fileURL options:0 error:nil];

    [manager POST:@"BACKEND_API_PATH"
        parameters:mutableParams
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                  { [formData appendPartWithFileURL:fileURL name:@"image" error:nil]; }
        success:^(AFHTTPRequestOperation *operation, id responseObject)
                { handler(responseObject, nil); }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
                {
            NSLog(@"Error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
            handler(nil, error);
        }];
}

+ (void)setRequestHeaders:(NSMutableURLRequest *)request
{

    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
    if(!uuid)
    {
        uuid = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [request setValue:uuid forHTTPHeaderField:@"UUID"];

    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
    if(pushToken)
    {
        [request setValue:pushToken forHTTPHeaderField:@"PUSH_TOKEN"];
    }

    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"SYSTEM_VERSION"];

    [request setValue:[NSLocale preferredLanguages][0] forHTTPHeaderField:@"PREFERRED_LANGUAGE"];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    [request setValue:majorVersion forHTTPHeaderField:@"APP_VERSION"];
}

+ (void)sendLog
{

    [self loadAction:@"log" complete:^(id result, NSError *error) {}];

    // Optional: automatically send uncaught exceptions to Google Analytics.
    //    [GAI sharedInstance].trackUncaughtExceptions = YES;
    //    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //    [GAI sharedInstance].dispatchInterval = 20;
    //    // Optional: set debug to YES for extra debugging information.
    //    //[GAI sharedInstance].debug = YES;
    //    // Create tracker instance.
    //    //id<GAITracker> tracker =
    //    [[GAI sharedInstance] trackerWithTrackingId:@"UA-6835255-4"];
    //

    // Send Log

    //[[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*10];

    // NSDate *lastLog = [[NSUserDefaults standardUserDefaults] objectForKey:@"LogLast"];
    // if((ALLWAYS_SEND_LOG || !lastLog || [[NSDate date] timeIntervalSinceDate:lastLog] > 60*60*24*2) &&
    // ![[NSUserDefaults standardUserDefaults] boolForKey:@"sendLog"]) {
    //[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LogLast"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
