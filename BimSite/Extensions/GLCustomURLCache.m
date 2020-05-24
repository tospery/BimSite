////
////  GLCustomURLCache.m
////  BimSite
////
////  Created by  方世勇 on 2017/9/23.
////  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
////
//
//#import "GLCustomURLCache.h"
//#import "Util.h"
//#import "Reachability.h"
//
//@interface GLCustomURLCache()
//@property(assign, nonatomic) NSInteger cacheTime;
//@property(strong, nonatomic) NSString *diskPath;
//@property(strong, nonatomic) NSMutableDictionary *responseDictionary;
//@end
//
//@implementation GLCustomURLCache
//
//+ (void) configCache {
//    GLCustomURLCache *cache = [[GLCustomURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024 diskCapacity:1024 * 1024 * 1024 diskPath:nil cacheTime:0];
//    [self setSharedURLCache:cache];
//    
//}
//
//- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime {
//    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
//        self.cacheTime = cacheTime;
//        if (path)
//            self.diskPath = path;
//        else
//            self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        
//        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
//    }
//    return self;
//}
//
//- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
//    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
//        return [super cachedResponseForRequest:request];
//    }
//    
//    return [self dataFromRequest:request];
//}
//
//- (void)removeAllCachedResponses {
//    [super removeAllCachedResponses];
//    
//    [self deleteCacheFolder];
//}
//
//- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
//    [super removeCachedResponseForRequest:request];
//    
//    NSString *url = request.URL.absoluteString;
//    NSString *fileName = [self cacheRequestFileName:url];
//    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
//    NSString *filePath = [self cacheFilePath:fileName];
//    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:filePath error:nil];
//    [fileManager removeItemAtPath:otherInfoPath error:nil];
//}
//
//
//#pragma mark - custom url cache
//- (NSString *)cacheFolder {
//    return @"URLCACHE";
//}
//
//- (void)deleteCacheFolder {
//    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager removeItemAtPath:path error:nil];
//}
//
//- (NSString *)cacheFilePath:(NSString *)file {
//    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL isDir;
//    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
//        
//    } else {
//        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    return [NSString stringWithFormat:@"%@/%@", path, file];
//}
//
//- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
//    return [Util md5Hash:requestUrl];
//}
//
//- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
//    return [Util md5Hash:[NSString stringWithFormat:@"%@-otherInfo", requestUrl]];
//}
//
//- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request {
//    NSString *url = request.URL.absoluteString;
//    NSString *fileName = [self cacheRequestFileName:url];
//    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
//    NSString *filePath = [self cacheFilePath:fileName];
//    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
//    NSDate *date = [NSDate date];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:filePath] && ![Reachability networkAvailable]) {
//        BOOL expire = false;
//        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
//        
//        if (self.cacheTime > 0) {
//            NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
//            if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
//                expire = true;
//            }
//        }
//        
//        if (expire == false) {
//            NSLog(@"data from cache ...");
//            
//            NSData *data = [NSData dataWithContentsOfFile:filePath];
//            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
//                                                                MIMEType:[otherInfo objectForKey:@"MIMEType"]
//                                                   expectedContentLength:data.length
//                                                        textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
//            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
//            return cachedResponse;
//        } else {
//            NSLog(@"cache expire ... ");
//            
//            [fileManager removeItemAtPath:filePath error:nil];
//            [fileManager removeItemAtPath:otherInfoPath error:nil];
//        }
//    }
//    if (![Reachability networkAvailable]) {
//        return nil;
//    }
//    
//    //sendSynchronousRequest请求也要经过NSURLCache
//    __block NSCachedURLResponse * cachedResponse = nil;
//    id boolExsite = [self.responseDictionary objectForKey:url];
//    if (boolExsite == nil) {
//        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
//        
//        // NSURLResponse *response = nil;
//        //        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//        
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        configuration.timeoutIntervalForRequest = 99999;
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
//        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            
//            if (!error) {
//                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                [self.responseDictionary removeObjectForKey:url];
//                NSLog(@"%@", dataStr);
//            } else {
//                NSLog(@"error is %@", error.localizedDescription);
//            }
//            //save to cache
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
//                                  response.MIMEType, @"MIMEType",
//                                  response.textEncodingName, @"textEncodingName", nil];
//            [dict writeToFile:otherInfoPath atomically:YES];
//            [data writeToFile:filePath atomically:YES];
//            
////            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
//            
//        }];
//        // 恢复线程, 启动任务
//        [dataTask resume];
//        
////        return cachedResponse;
//    }
//    return nil;
//}
//
//@end
