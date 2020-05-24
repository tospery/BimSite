//
//  UIWebView+BSWebView.m
//  BimSite
//
//  Created by  方世勇 on 2017/9/24.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "UIWebView+BSWebView.h"
#import "AFNetworkReachabilityManager.h"

@implementation UIWebView (BSWebView)

- (void)loadUrl:(NSString*)url {
//    //********liuxu********
//    //没有网络则使用缓存策略，否则使用服务器
//    __block NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
//    __weak typeof(self)weakSelf = self;
//    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
//    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case AFNetworkReachabilityStatusNotReachable://无网络
//                policy = NSURLRequestReturnCacheDataElseLoad;
//                break;
//            default:
//                break;
//        }
//        
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:policy timeoutInterval:30];
//        // 加载指定URL对应的网址
//        [weakSelf loadRequest:request];
//    }];
    
    NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
    // policy = NSURLRequestReloadIgnoringLocalCacheData;
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        policy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:policy timeoutInterval:30];
    // 加载指定URL对应的网址
    [self loadRequest:request];
}

@end



