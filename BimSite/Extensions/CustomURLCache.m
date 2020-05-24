//
//  CustomURLCache.m
//  LiLottery
//
//  Created by 杨建祥 on 16/6/5.
//  Copyright © 2016年 tospery. All rights reserved.
//

#import "CustomURLCache.h"
#import "Reachability.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface CustomURLCache(private)

- (NSString *)cacheFolder;
- (NSString *)cacheFilePath:(NSString *)file;
- (NSString *)cacheRequestFileName:(NSString *)requestUrl;
- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl;
- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request;
- (void)deleteCacheFolder;

@end

@implementation CustomURLCache

@synthesize cacheTime = _cacheTime;
@synthesize diskPath = _diskPath;
@synthesize responseDictionary = _responseDictionary;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime {
    if (self = [self initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        self.cacheTime = cacheTime;
        if (path)
        self.diskPath = path;
        else
        self.diskPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        self.responseDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    _diskPath = nil;
    
    [_responseDictionary removeAllObjects];
    _responseDictionary = nil;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    return [self dataFromRequest:request];
}

- (void)removeAllCachedResponses {
    [super removeAllCachedResponses];
    
    [self deleteCacheFolder];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    [super removeCachedResponseForRequest:request];
    
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:otherInfoPath error:nil];
}

#pragma mark - custom url cache

- (NSString *)cacheFolder {
    return @"URLCACHE";
}

- (void)deleteCacheFolder {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)cacheFilePath:(NSString *)file {
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.diskPath, [self cacheFolder]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/%@", path, file];
}

- (NSString *)exMD5Bit32String:(NSString *)str {
    const char *cStr = str.UTF8String;
    unsigned char digits[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digits);
    NSMutableString *result = [NSMutableString stringWithCapacity:2 * CC_MD5_DIGEST_LENGTH];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [result appendFormat:@"%02x", digits[i]];
    }
    return result;
}

- (NSString *)exMD5Bit16String:(NSString *)str {
    NSString *md5Bit32 = [self exMD5Bit32String:str]; // 提取32位MD5散列的中间16位
    NSString *result = [[md5Bit32 substringToIndex:24] substringFromIndex:8]; // 即9～25位
    return result;
}

//- (NSString *)exSHA1String:(NSString *)str {
//    // see http://www.makebetterthings.com/iphone/how-to-get-md5-and-sha1-in-objective-c-ios-sdk/
//    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    
//    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
//    
//    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
//    
//    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
//        [output appendFormat:@"%02x", digest[i]];
//    }
//    
//    return output;
//}

- (NSString *)cacheRequestFileName:(NSString *)requestUrl {
    return [self exMD5Bit32String:requestUrl]; // [requestUrl exMD5Bit32String]; // [Util md5Hash:requestUrl];
}

- (NSString *)cacheRequestOtherInfoFileName:(NSString *)requestUrl {
    NSString *str = [NSString stringWithFormat:@"%@-otherInfo", requestUrl];
    return [self exMD5Bit32String:str]; // [[NSString stringWithFormat:@"%@-otherInfo", requestUrl] exMD5Bit32String];
}

- (NSCachedURLResponse *)dataFromRequest:(NSURLRequest *)request {
    NSString *url = request.URL.absoluteString;
    NSString *fileName = [self cacheRequestFileName:url];
    NSString *otherInfoFileName = [self cacheRequestOtherInfoFileName:url];
    NSString *filePath = [self cacheFilePath:fileName];
    NSString *otherInfoPath = [self cacheFilePath:otherInfoFileName];
    NSDate *date = [NSDate date];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        BOOL expire = false;
        NSDictionary *otherInfo = [NSDictionary dictionaryWithContentsOfFile:otherInfoPath];
        
        if (self.cacheTime > 0) {
            NSInteger createTime = [[otherInfo objectForKey:@"time"] intValue];
            if (createTime + self.cacheTime < [date timeIntervalSince1970]) {
                expire = true;
            }
        }
        
        if (expire == false) {
            NSLog(@"data from cache ...");
            
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                                MIMEType:[otherInfo objectForKey:@"MIMEType"]
                                                   expectedContentLength:data.length
                                                        textEncodingName:[otherInfo objectForKey:@"textEncodingName"]];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            return cachedResponse;
        } else {
            NSLog(@"cache expire ... ");
            
            [fileManager removeItemAtPath:filePath error:nil];
            [fileManager removeItemAtPath:otherInfoPath error:nil];
        }
    }
    if (![CustomURLCache networkAvailable]/*![AFNetworkReachabilityManager sharedManager].isReachable*/) {
        return nil;
    }
    __block NSCachedURLResponse *cachedResponse = nil;
    //sendSynchronousRequest请求也要经过NSURLCache
    id boolExsite = [self.responseDictionary objectForKey:url];
    if (boolExsite == nil) {
        [self.responseDictionary setValue:[NSNumber numberWithBool:TRUE] forKey:url];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
         {
             if (response && data) {
                 
                 [self.responseDictionary removeObjectForKey:url];
                 
                 if (error) {
                     NSLog(@"error : %@", error);
                     NSLog(@"not cached: %@", request.URL.absoluteString);
                     cachedResponse = nil;
                 }
                 
                 NSLog(@"cache url --- %@ ",url);
                 
                 //save to cache
                 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]], @"time",
                                       response.MIMEType, @"MIMEType",
                                       response.textEncodingName, @"textEncodingName", nil];
                 [dict writeToFile:otherInfoPath atomically:YES];
                 [data writeToFile:filePath atomically:YES];
                 
                 cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
             }
             
         }];
        
        return cachedResponse;
        //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
    }
    return nil;
}

+(BOOL)networkAvailable
{
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable) {
        return YES;
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
        return YES;
    }
    return NO;
}

@end
