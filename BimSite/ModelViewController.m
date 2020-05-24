//
//  ModelViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "ModelViewController.h"
#import "UIColor+BSUIColor.h"
#include "APPDefine.h"
#import "AppModel.h"
#import "HSDownloadManager.h"
#import "QrcodeViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CocoaSecurity/Base64.h>
#import <CocoaSecurity/CocoaSecurity.h>
#import <MJExtension/MJExtension.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "UIWebView+BSWebView.h"
#import <SSZipArchive/SSZipArchive.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UserService.h"
#import "UIColor+BSUIColor.h"

@interface ModelViewController ()
@property (nonatomic, strong) NSURL *retryURL;
@property (nonatomic, strong) UIView *errorView;

@end

@implementation ModelViewController
@synthesize mQrcodeResult;

UIActivityIndicatorView* _activityIndicatorModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.scalesPageToFit = NO;
    // 为UIWebView控件设置委托
    self.webView.delegate = self;
    // 创建一个UIActivityIndicatorView控件
    _activityIndicatorModel = [[UIActivityIndicatorView alloc]
                               initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    // 控制UIActivityIndicatorView显示在当前View的中央
    [_activityIndicatorModel setCenter: self.view.center];
    _activityIndicatorModel.activityIndicatorViewStyle
    = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview : _activityIndicatorModel];
    // 隐藏_activityIndicator控件
    _activityIndicatorModel.hidden = YES;
    
    AppModel *appModel = [AppModel readModel];
    
    NSString* reqAddr = [NSString stringWithFormat:@"http://%@/BimSiteApp/model/index?token=%@", appModel.h5server, appModel.token];//@"http://m.baidu.com";
    [self.webView loadUrl:reqAddr];
    
    //NSString* reqAddr = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqAddr]];
    
//    NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
//    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
//        policy = NSURLRequestReloadIgnoringLocalCacheData;
//    }
//
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:reqAddr] cachePolicy:policy timeoutInterval:30];
//    // 加载指定URL对应的网址
//    [self.webView loadRequest:request];
    
    // 本地
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadHTMLString:appHtml baseURL:baseURL];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backRootNoti:) name:@"backRoot" object:nil];
}

- (void)backRootNoti:(NSNotification*)noti {
    NSNumber* index = [noti.userInfo objectForKey:@"index"];
    
    NSString *link = self.webView.request.URL.absoluteString;
    NSRange range = [link rangeOfString:@"/BimSiteApp/model/index?token="];
    if (1 == index.integerValue &&
        NSNotFound != range.location) {
        return;
    }
    
    if (index.integerValue == 1) {
        self.isLocalHTML = NO;
        
        AppModel *appModel = [AppModel readModel];
        NSString* reqAddr = [NSString stringWithFormat:@"http://%@/BimSiteApp/model/index?token=%@", appModel.h5server, appModel.token];
        [self.webView loadUrl:reqAddr];
        
//        if (self.webView.canGoBack) {
//            [self.webView goBack];
//        }
    }
}

// 当UIWebView开始加载时激发该方法
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // 显示_activityIndicator控件
    _activityIndicatorModel.hidden = NO;
    // 启动_activityIndicator控件的转动
    [_activityIndicatorModel startAnimating] ;
    
    if (self.errorView.tag == 101) {
        self.errorView.tag = 0;
        [self.errorView removeFromSuperview];
    }
}
// 当UIWebView加载完成时激发该方法
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];//貌似只要这一个就行了
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 停止_activityIndicator控件的转动
    [_activityIndicatorModel stopAnimating];
    // 隐藏_activityIndicator控件
    _activityIndicatorModel.hidden = YES;
    
    if (self.errorView.tag == 101) {
        self.errorView.tag = 0;
        [self.errorView removeFromSuperview];
    }
    
    AppModel *appModel = [AppModel readModel];
    if (appModel) {
        NSString* token = [NSString stringWithFormat:@"getUserToken('%@')", appModel.token];
        [self.webView stringByEvaluatingJavaScriptFromString:token];
        
        NSString* userName = [NSString stringWithFormat:@"getUserName('%@')", appModel.userName];
        [self.webView stringByEvaluatingJavaScriptFromString:userName];
    }
    
    if (self.isLocalHTML) {
        NSString *h5 = [NSString stringWithFormat:@"getH5Address('%@')", appModel.h5server];
        [self.webView stringByEvaluatingJavaScriptFromString:h5];
        
        NSString *ws = [NSString stringWithFormat:@"getAddress('%@')", appModel.wsserver];
        [self.webView stringByEvaluatingJavaScriptFromString:ws];
    }
}
// 当UIWebView加载失败时激发该方法
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // 停止_activityIndicator控件的转动
    [_activityIndicatorModel stopAnimating];
    // 隐藏_activityIndicator控件
    _activityIndicatorModel.hidden = YES;
    NSLog(@"aaa: code = %ld, reason = %@", error.code, error.localizedDescription);
    // 使用UIAlertView显示错误信息
    if (-1004 == error.code) {
        if (!self.errorView) {
            // CGRect frame = CGRectMake(0, 64, self.webView.bounds.size.width, self.webView.bounds.size.height - 64);
            self.errorView = [[UIView alloc] initWithFrame:self.webView.bounds];
            self.errorView.backgroundColor = [UIColor whiteColor];
            
            //            UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
            //            navBar.barTintColor = JXColorHex(0x4D82FA);
            //            navBar.
            UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.webView.bounds.size.width, 44)];
            navView.backgroundColor =JXColorHex(0x4D82FA);
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = @"加载失败";
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:17];
            [titleLabel sizeToFit];
            [navView addSubview:titleLabel];
            titleLabel.center = navView.center;
//            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            backBtn.adjustsImageWhenHighlighted = NO;
//            [backBtn setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
//            [backBtn addTarget:self action:@selector(backWhenErrorPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [backBtn sizeToFit];
//            [navView addSubview:backBtn];
//            backBtn.center = navView.center;
//            backBtn.frame = CGRectMake(8, backBtn.frame.origin.y, backBtn.frame.size.width, backBtn.frame.size.height);
            [self.errorView addSubview:navView];
            
            UIImage *image = [UIImage imageNamed:@"jxres_error_network"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [self.errorView addSubview:imageView];
            imageView.center = self.errorView.center;
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y - 80, imageView.frame.size.width, imageView.frame.size.height);
            
            UILabel *label = [[UILabel alloc] init];
            label.text = @"您貌似没有连接网络哦~";
            label.font = [UIFont systemFontOfSize:15.0f];
            label.textColor = [UIColor lightGrayColor];
            [label sizeToFit];
            [self.errorView addSubview:label];
            label.center = self.errorView.center;
            label.frame = CGRectMake(label.frame.origin.x, imageView.frame.origin.y + imageView.frame.size.height + 8.0, label.frame.size.width, label.frame.size.height);
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btn setTitle:@" 重新加载 " forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(errorRetryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btn sizeToFit];
            [self.errorView addSubview:btn];
            btn.center = self.errorView.center;
            btn.frame = CGRectMake(btn.frame.origin.x, label.frame.origin.y + label.frame.size.height + 12.0, btn.frame.size.width, btn.frame.size.height);
        }
        
        if (self.errorView.tag != 101) {
            self.errorView.tag = 101;
            [self.webView addSubview:self.errorView];
        }
    }
}

- (void)errorRetryButtonPressed:(id)sender {
    if (self.retryURL) {
        [self.webView loadUrl:self.retryURL.absoluteString];
    }
}

- (void)backWhenErrorPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JS调用OC方法列表
- (void)finishView {
    [self dismissViewControllerAnimated:YES completion:^(void) {  }];
}

- (void)finishViewWidthData:(NSString *)data {
    NSString* paramData = data;
    [self dismissViewControllerAnimated:YES completion:^(void) {  }];
}

- (void)retry:(NSString *)url filename:(NSString *)name error:(NSError *)error {
    [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"网络已断开，请联网后继续" cancelButtonTitle:@"继续下载" otherButtonTitles:@[@"取消下载"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (0 == buttonIndex) {
            // 继续下载
            if ([AFNetworkReachabilityManager sharedManager].isReachable) {
                [self downloadFileWidthUrl:url andFileName:name];
            }else {
                [self retry:url filename:name error:error];
            }
        }
    }];
}

// TFJCGS-TJ6-K.zip TFJCGS-TJ6-K.3gd.json
- (void)downloadFileWidthUrl:(NSString *)Url andFileName:(NSString*)name {
    NSLog(@"下载地址：%@, 文件名：%@", Url, name);
    
    NSString *dlURL = Url;
    // dlURL = @"http://sw.bos.baidu.com/sw-search-sp/software/4170fd7b86b3f/thunder_mac_3.1.4.3146.dmg";
    
    if (![name hasSuffix:@".zip"]) {
        [SVProgressHUD showInfoWithStatus:@"模型链接错误！"];
        return;
    }
    
    NSArray *arr = [name componentsSeparatedByString:@".zip"];
    if (arr.count != 2) {
        [SVProgressHUD showInfoWithStatus:@"模型链接错误！"];
        return;
    }
    
    NSString *filename = arr.firstObject;
    if (filename.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"模型链接错误！"];
        return;
    }
    
//    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/json" withExtension:nil];
//    NSString *destPath = jsonURL.path;
//    destPath = [NSString stringWithFormat:@"%@/WebGlTest/%@/%@.3gd.json", destPath, filename, filename];
    
    NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5loc"];
    NSString *jsonURL = [NSString stringWithFormat:@"%@/Android_3DAir/json", pagePath];
    NSString *destPath = [NSString stringWithFormat:@"%@/WebGlTest/%@/%@.3gd.json", jsonURL, filename, filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:destPath];
    if (result) {
        NSLog(@"文件存在");
        // [SVProgressHUD showInfoWithStatus:@"正在渲染，请耐心等待..."];
        NSString *pm1 = [NSString stringWithFormat:@"json/WebGlTest/%@/%@.3gd.json", filename, filename];
        NSString *pm2 = [NSString stringWithFormat:@"json/WebGlTest/%@/%@/", filename, filename];
        NSString *js = [NSString stringWithFormat:@"openModel('%@', '%@')", pm1, pm2];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
        [self.webView stringByEvaluatingJavaScriptFromString:@"finishLoading()"];
        
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:nil];
    [[HSDownloadManager sharedInstance] download:dlURL andFileName:name progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"当前下载进度：%.2f%%", progress* 100);
        });
        
    } state:^(DownloadState state, NSError *error) {
        NSLog(@"state == %u", state);
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case DownloadStateStart:
                    break;
                    return ;//@"暂停";
                case DownloadStateSuspended:
                case DownloadStateFailed:
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD showInfoWithStatus:@"下载失败"];
//                    });
                    break;
                    return ;//@"开始";
                case DownloadStateCompleted:
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [SVProgressHUD showInfoWithStatus:@"下载失败"];
                    //                    });
                    
                    // NSLog(@"当前下载完成！");
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //                        [SVProgressHUD dismiss];
                    //                    });
                    // [SVProgressHUD showInfoWithStatus:@"下载成功"];
                    /// [SVProgressHUD dismiss];
                    
                    //NSString* fileFullPath = [NSString stringWithFormat:@"setDownloadFileResult('%@')", filePath];
                    // [self.webView stringByEvaluatingJavaScriptFromString:fileFullPath];
                    // [self performSelectorOnMainThread: @selector(setDownloadFileResult:) withObject: filePath waitUntilDone: NO];
                    
                   // NSString* filePath = [[HSDownloadManager sharedInstance] fileFullPath:name];
                    
//                    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/json" withExtension:nil];
//                    NSString *destPath = jsonURL.path;
//                    destPath = [NSString stringWithFormat:@"%@/WebGlTest/%@", destPath, filename];
//                    
//                    NSFileManager *fm = [NSFileManager defaultManager];
//                    if (![fm fileExistsAtPath:destPath]) {
//                        NSDictionary *dict = @{NSFilePosixPermissions: @493};
//                        
//                        [fm createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:dict error:nil];
//                    }
////                    BOOL aaa = [fm isReadableFileAtPath:destPath];
////                    BOOL bbb = [fm isWritableFileAtPath:destPath];
//                    NSDictionary *filePro = [fm attributesOfItemAtPath:destPath error:nil];
//                    NSLog(@"%@",filePro);
//                    
//                    NSLog(@"解压目录: %@", destPath);
                    
                    NSLog(@"当前下载完成！");
                    
                    NSString* filePath = [[HSDownloadManager sharedInstance] fileFullPath:name];
                    
                    NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5loc"];
                    NSString *jsonURL = [NSString stringWithFormat:@"%@/Android_3DAir/json", pagePath];
                    NSString *destPath = [NSString stringWithFormat:@"%@/WebGlTest/%@", jsonURL, filename];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if (![fileManager fileExistsAtPath:filePath]) {
                        
                        if (-1005 == error.code) {
                            [SVProgressHUD dismiss];
                            [self retry:dlURL filename:name error:error];
                        }else {
                            [SVProgressHUD showInfoWithStatus:@"下载失败"];
                        }
                        
                        return;
                    }
                    
                    [SSZipArchive unzipFileAtPath:filePath toDestination:destPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            [fileManager removeItemAtPath:filePath error:nil];
                            [self downloadFileWidthUrl:dlURL andFileName:name];
                            [SVProgressHUD dismiss];
                        }else {
                            [SVProgressHUD showInfoWithStatus:@"模型解压失败！"];
                        }
                    }];
                    break;
                    return ;//@"完成";
            }
        });
    }];

    
    return;
    
    
//    NSString* filePath = [[HSDownloadManager sharedInstance] fileFullPath:fileName];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL result = [fileManager fileExistsAtPath:filePath];
//    if (result) {
//        NSLog(@"文件已存在");
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//        [SVProgressHUD showWithStatus:nil];
//        [self setDownloadFileResult:filePath];
//        return;
//    }
//    
//    NSLog(@"下载地址：%@, 文件名：%@", Url, fileName);
//    //    //    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
//    //    //    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//    
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    [SVProgressHUD showWithStatus:nil];
//
//    [[HSDownloadManager sharedInstance] download:Url andFileName:fileName progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // NSLog(@"当前下载进度：%.2f%%", progress* 100);
//        });
//        
//    } state:^(DownloadState state) {
//        NSLog(@"state == %u", state);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            switch (state) {
//                case DownloadStateStart:
//                    return ;//@"暂停";
//                case DownloadStateSuspended:
//                case DownloadStateFailed:
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD showInfoWithStatus:@"下载失败"];
//                    });
//                    return ;//@"开始";
//                case DownloadStateCompleted:
////                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [SVProgressHUD showInfoWithStatus:@"下载失败"];
////                    });
//                    
//                    NSLog(@"当前下载完成！");
//                    //                    dispatch_async(dispatch_get_main_queue(), ^{
//                    //                        [SVProgressHUD dismiss];
//                    //                    });
//                    // [SVProgressHUD showInfoWithStatus:@"下载成功"];
//                    /// [SVProgressHUD dismiss];
//                    
//                    NSString* filePath = [[HSDownloadManager sharedInstance] fileFullPath:fileName];
//                    //NSString* fileFullPath = [NSString stringWithFormat:@"setDownloadFileResult('%@')", filePath];
//                    // [self.webView stringByEvaluatingJavaScriptFromString:fileFullPath];
//                    [self performSelectorOnMainThread: @selector(setDownloadFileResult:) withObject: filePath waitUntilDone: NO];
//                    return ;//@"完成";
//            }
//        });
//    }];
    
}

-(void)setDownloadFileResult:(NSString*)fileFullPath
{
    NSLog(@"setDownloadFileResult");
    
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
        id obj = [data mj_JSONObject];
        
        NSString *jsonString = nil; // [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        if (obj) {
            data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
            jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }else {
            jsonString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        }
        
        NSUInteger i = 0;
        NSUInteger size = 256; // 256;
        NSUInteger length = jsonString.length;
        
        for (i = 0; i < length; i += size) {
            @autoreleasepool {
                NSInteger len = size;
                if (i + size > length) {
                    len = length - i;
                }
                NSRange range = NSMakeRange(i, len);
                NSString *str = [jsonString substringWithRange:range];
                NSString *js = [NSString stringWithFormat:@"appendStr('%@')", str];
                [self.webView stringByEvaluatingJavaScriptFromString:js];
            }
        }
    }
    
    NSLog(@"传输完成，开始渲染");
    [self.webView stringByEvaluatingJavaScriptFromString:@"openAppModel()"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"finishLoading()"];
    [SVProgressHUD dismiss];
    
    
    //    NSData* data = [NSData dataWithContentsOfFile:fileFullPath];
    //
    //    NSString* jsonTmp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //
    //
    //    NSInteger i;
    //    for (i = 0; i < jsonTmp.length; i=i+256) {
    //        NSInteger fromLen = 0;
    //        if(i+256 > jsonTmp.length){
    //            fromLen = jsonTmp.length - i;
    //        }
    //        else{
    //            fromLen = 256;
    //        }
    //        NSRange range = NSMakeRange(i, fromLen);
    //        NSString* subTemp = [jsonTmp substringWithRange:range];
    //
    //        NSData *nsdata = [subTemp dataUsingEncoding:NSUTF8StringEncoding];
    //        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    //
    //        NSString* resultContnet = [NSString stringWithFormat:@"appendStr('%@')", base64Encoded];
    //        [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    //        //[NSThread sleepForTimeInterval:1];
    //    }
    //
    //
    //  /*  if(i - 256 < jsonTmp.length){
    //        NSString* subTemp = [jsonTmp substringFromIndex:i];
    //        NSData *nsdata = [subTemp dataUsingEncoding:NSUTF8StringEncoding];
    //        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    //
    //        NSString* resultContnet = [NSString stringWithFormat:@"appendStr('%@')", base64Encoded];
    //        [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    //
    //    }
    //    */
    //    [self.webView stringByEvaluatingJavaScriptFromString:@"openAppModel()"];
    
    
    //@autoreleasepool {
    
    //}
    
    //    // NSData* data = [NSData dataWithContentsOfFile:fileFullPath];
    //    NSString* jsonString =  [[NSString alloc] initWithContentsOfFile:fileFullPath encoding:NSUTF8StringEncoding error:nil];
    ////    NSLog(@"jsonString = %@, %ld, %@", [jsonString substringToIndex:256], jsonString.length, fileFullPath);
    ////
    ////    [[NSString alloc] initWithContentsOfFile:<#(nonnull NSString *)#> usedEncoding:<#(nullable NSStringEncoding *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
    ////    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"jsonString = %@, %ld, %@", [jsonString substringToIndex:256], jsonString.length, fileFullPath);
    
//        NSData* data = [NSData dataWithContentsOfFile:fileFullPath];
//        NSArray *arr = [NSArray arrayWithContentsOfFile:fileFullPath];
//        
//        [NSJSONSerialization
////        data = [NSJSONSerialization dataWithJSONObject:<#(nonnull id)#> options:<#(NSJSONWritingOptions)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
////        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////        NSString *jsonString = [data base64EncodedString];
////        jsonString = [jsonString base64DecodedString];
        
//        NSArray *arr = [NSArray arrayWithContentsOfFile:fileFullPath];
//        NSData *data = [NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
//        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
//        id obj = [data mj_JSONObject];
//        
//        // NSString *jsonString = data.description;
//        // NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSMutableString *responseString = [NSMutableString stringWithString:jsonString];
//        NSString *character = nil;
//        for (int i = 0; i < responseString.length; i ++) {
//            character = [responseString substringWithRange:NSMakeRange(i, 1)];
//            if ([character isEqualToString:@"\a"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\b"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\f"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\n"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\r"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\t"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\v"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\\"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\""])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//            else if ([character isEqualToString:@"\'"])
//                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//        }
//        jsonString = responseString;
        
        //id obj = [data mj_JSONObject];
    
//        for (i = 0; i < length; i += size) {
//            if (0 == i) {
//                @autoreleasepool {
//                    NSLog(@"第%ld次", (long)i / size);
//                    NSInteger len = size;
//                    if (i + size > length) {
//                        len = length - i;
//                    }
//                    NSRange range = NSMakeRange(i, len);
//                    NSString *str = [jsonString substringWithRange:range];
//                    NSString* resultContnet = [NSString stringWithFormat:@"appendStr('%@')", str];
//                    [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
//                }
//            }else {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    @autoreleasepool {
//                        NSLog(@"第%ld次", (long)i / size);
//                        NSInteger len = size;
//                        if (i + size > length) {
//                            len = length - i;
//                        }
//                        NSRange range = NSMakeRange(i, len);
//                        NSString *str = [jsonString substringWithRange:range];
//                        NSString* resultContnet = [NSString stringWithFormat:@"appendStr('%@')", str];
//                        [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
//                    }
//                });
//            }
//        }
}

- (void)scanQrcode {
    [self performSegueWithIdentifier:@"Push2Qrcode" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Push2Qrcode"]){
        ((QrcodeViewController*)segue.destinationViewController).webController = self;
    }
}

-(void)scanQrcodeForResult:(NSString*)result{
    
    [self performSelectorOnMainThread: @selector(setWebQrcodeContent) withObject: nil waitUntilDone: NO];
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [self setWebQrcodeContent];
    //});
}

-(void)setWebQrcodeContent {
    NSString* resultContnet = [NSString stringWithFormat:@"scanQrcodeResult('%@')", mQrcodeResult];
    [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
}

- (void)showModelHtml {
//    NSString* reqAddr = @"http://www.baidu.com";// [NSString stringWithFormat:@"http://%@/BimSiteApp/model/index?token=%@", appModel.h5server, appModel.token];//@"http://m.baidu.com";
//    [self.webView loadUrl:reqAddr];
    
//    ModelViewController *vc = [[ModelViewController alloc] init];
//    vc.view.backgroundColor = [UIColor whiteColor];
//    vc.isLocalHTML = YES;
//    [self presentViewController:vc animated:YES completion:NULL];
    
    self.isLocalHTML = YES;
    
//    NSURL *localURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/model3D.html" withExtension:nil];
//    NSURLRequest *localRequest = [NSURLRequest requestWithURL:localURL];
//    [self.webView loadRequest:localRequest];
    
    AppModel *appModel = [AppModel readModel];
    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//    NSString *info = [NSString stringWithFormat:@" bimaddress_%@", appModel.wsserver];
//    NSString *newAgent = [oldAgent stringByAppendingString:info];
//    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    
    NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5loc"];
    NSString *htmlPath = [NSString stringWithFormat:@"%@/Android_3DAir/model3D.html", pagePath];
    NSURL *localURL = [NSURL fileURLWithPath:htmlPath];
    NSMutableURLRequest *localRequest = [NSMutableURLRequest requestWithURL:localURL];
    [localRequest setValue:appModel.wsserver forHTTPHeaderField:@"address"];

    NSLog(@"address: %@", appModel.wsserver);
    
    
    [self.webView loadRequest:localRequest];
}

- (void)getNetworkState {
    NSInteger state = 0;
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        state = 1;
    }
    
    NSString *js = [NSString stringWithFormat:@"setNetworkState('%ld')", (long)state];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)getBIMAddress {
    AppModel *appModel = [AppModel readModel];
    NSString *js = [NSString stringWithFormat:@"setBIMAddress('%@')", appModel.wsserver];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)logout {
    //NSString *info = @"请注销登录";
    //[self showMsg:info];
    //还需要 调注销接口
    AppModel *appModel = [AppModel readModel];
    if (appModel) {
        [UserService logoutWithToken:appModel.token andWidthServerAddress:appModel.wsserver];
        [appModel logout];
        //        appModel.token = nil;
        //        [appModel saveModel];
    }
    [appDelegate logout];//成功的处理
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    self.retryURL = request.URL;
    //OC调用JS是基于协议拦截实现的 下面是相关操作
    NSString *absolutePath = request.URL.absoluteString;
//    // YJX_TODO
//    if ([absolutePath containsString:@"&amp;fileName="]) {
//        absolutePath = @"rrcc://downloadFileWidthUrl_andFileName_?http://182.150.20.168:8104/TFSD_BIM/vault/vaultserver.aspx?dbName=TFSD&fileId=FD599951CDA14FF9A0E7109E3665BB7B&fileName=TFSD1.json&vaultId=67BBB9204FE84A8981ED8313049BA06C&TFSD1.json";
//    }
    // absolutePath = [absolutePath stringByReplacingOccurrencesOfString:@"&amp" withString:@"&"];
    
    NSString *scheme = @"rrcc://";
    
    if ([absolutePath hasPrefix:scheme]) {
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        
        if ([subPath containsString:@"?"]) {//1个或多个参数
            if ([subPath containsString:@"&"]) {//多个参数
                // subPath = [subPath stringByReplacingOccurrencesOfString:@"&amp" withString:@"|BimSite|"];
                NSArray *components = [subPath componentsSeparatedByString:@"?"];
                NSString *methodName = [components firstObject];
                methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
                SEL sel = NSSelectorFromString(methodName);
                
                NSString *parameter = [components lastObject];
                NSArray *params = [parameter componentsSeparatedByString:@"&"];
                
                if (params.count >= 2 && components.count == 3 ) {
                    if ([self respondsToSelector:sel]) {
                        NSString *server = [components objectAtIndex:1];
                        NSMutableString *downloadURL = [NSMutableString stringWithFormat:@"%@?",server];
                        for(int i = 0 ; i < params.count-1; i++) {
                            [downloadURL appendFormat:@"%@",[params objectAtIndex:i]];
                            if (i != params.count - 2) {
                                [downloadURL appendFormat:@"&"];
                            }
                        }
                        
                        NSString *fileName = [params lastObject];
//                        if ([fileName isEqualToString:@"amp;fileName="]) {
//                            fileName = @"TFJCGS-TJ6-K.zip";
//                        }
                        [self performSelector:sel withObject:downloadURL withObject:fileName];
                    }else {
                        [SVProgressHUD showInfoWithStatus:@"模型链接错误！"];
                    }
                }else {
                    [SVProgressHUD showInfoWithStatus:@"模型链接错误！"];
                }

                
//                if (params.count >= 2 && components.count == 3) {
//                    NSString *downloadURL = [params firstObject];
//                    downloadURL = [NSString stringWithFormat:@"%@?%@", components[1], downloadURL];
//                    downloadURL = [downloadURL stringByReplacingOccurrencesOfString:@"|BimSite|" withString:@"&amp"];
//                    NSString *fileName = [params lastObject];
//                    if ([fileName isEqualToString:@"amp;fileName="]) {
//                        fileName = @"TFJCGS-TJ6-K.zip";
//                    }
//                    [self performSelector:sel withObject:downloadURL withObject:fileName];
//                }
                
//                NSArray *components = [subPath componentsSeparatedByString:@"?"];
//                
//                NSString *methodName = [components firstObject];
//                
//                methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
//                SEL sel = NSSelectorFromString(methodName);
//                
//                NSString *parameter = [components lastObject];
//                NSArray *params = [parameter componentsSeparatedByString:@"&"];
//                
//                if (params.count >= 2 && components.count >= 2 ) {
//                    if ([self respondsToSelector:sel]) {
//                        NSString *server = [components objectAtIndex:1];
//                        NSMutableString *downloadURL = [NSMutableString stringWithFormat:@"%@?",server];
//                        for(int i = 0 ; i < params.count-1; i++) {
//                            [downloadURL appendFormat:@"%@",[params objectAtIndex:i]];
//                            if (i != params.count - 2) {
//                                [downloadURL appendFormat:@"&"];
//                            }
//                        }
//                        
//                        NSString *fileName = [params lastObject];
//                        // fileName = @"TFJCGS-TJ6-K.3gd.json"; // YJX_TODO
//                        if ([fileName isEqualToString:@"amp;fileName="]) {
//                            fileName = @"TFJCGS-TJ6-K.zip";
//                        }
//                        [self performSelector:sel withObject:downloadURL withObject:fileName];
//                    }
//                }
                
                
            } else {//1个参数
                NSArray *components = [subPath componentsSeparatedByString:@"?"];
                
                NSString *methodName = [components firstObject];
                methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
                SEL sel = NSSelectorFromString(methodName);
                
                NSString *parameter = [components lastObject];
                
                if ([self respondsToSelector:sel]) {
                    [self performSelector:sel withObject:parameter];
                }
                
            }
            
        } else {//没有参数
            NSString *methodName = [subPath stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            SEL sel = NSSelectorFromString(methodName);
            
            if ([self respondsToSelector:sel]) {
                [self performSelector:sel];
            }
        }
    }
    
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
