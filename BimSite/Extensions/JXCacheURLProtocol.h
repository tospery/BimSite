////
////  JXCacheURLProtocol.h
////  LiLottery
////
////  Created by 杨建祥 on 16/2/18.
////  Copyright © 2016年 tospery. All rights reserved.
////
//
//#ifdef JXEnableLibReachability
#import <Foundation/Foundation.h>

@interface JXCacheURLProtocol : NSURLProtocol
+ (NSSet *)supportedSchemes;
+ (void)setSupportedSchemes:(NSSet *)supportedSchemes;

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest;
- (BOOL)useCache;

+ (void)setCachingEnabled:(BOOL)enabled;
@end
//#endif
