//
//  HomeViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "HomeViewController.h"
#import "UIColor+BSUIColor.h"
#include "APPDefine.h"
#import "AppModel.h"
#import "HSDownloadManager.h"
#import "QrcodeViewController.h"
#import "UserService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "UIWebView+BSWebView.h"
#import "TodoModel.h"
#import <SSZipArchive/SSZipArchive.h>
#import "AppDelegate.h"
#import "UserService.h"

@interface HomeViewController ()
@property (nonatomic, assign) NSInteger isFirst;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HomeViewController

@synthesize mQrcodeResult;
UIActivityIndicatorView* _activityIndicator;

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)goWork {
    AppModel *appModel = [AppModel readModel];
    NSString* reqAddr = [NSString stringWithFormat:@"http://%@/BimSiteApp/work.jsp?token=%@",appModel.h5server, appModel.token];//@"http://m.baidu.com";
    [self.webView loadUrl:reqAddr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.contentInset = UIEdgeInsetsZero;
    
    // Do any additional setup after loading the view.
    self.webView.scalesPageToFit = NO;
    // 为UIWebView控件设置委托
    self.webView.delegate = self;
    // 创建一个UIActivityIndicatorView控件
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    // 控制UIActivityIndicatorView显示在当前View的中央
    [_activityIndicator setCenter: self.view.center];
    _activityIndicator.activityIndicatorViewStyle
    = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview : _activityIndicator];
    // 隐藏_activityIndicator控件
    _activityIndicator.hidden = YES;
    
    AppModel *appModel = [AppModel readModel];
    NSString* reqAddr = [NSString stringWithFormat:@"http://%@/BimSiteApp/index?token=%@",appModel.h5server, appModel.token];//@"http://m.baidu.com";
   //reqAddr = @"http://139.199.206.175/BimSiteApp/test.html";
    [self.webView loadUrl:reqAddr];
    
    
    // 本地图片
//    NSURL *localURL = [[NSBundle mainBundle] URLForResource:@"localimg/test.html" withExtension:nil];
//    NSURLRequest *localRequest = [NSURLRequest requestWithURL:localURL];
//    [self.webView loadRequest:localRequest];
    
    
    
    //NSString* reqAddr = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
    //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqAddr]];
    
//    NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
//    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
//        policy = NSURLRequestReloadIgnoringLocalCacheData;
//    }
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:reqAddr] cachePolicy:policy timeoutInterval:30];
//    
//    // 加载指定URL对应的网址
//    [self.webView loadRequest:request];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//        [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
//        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//        [SVProgressHUD showWithStatus:nil];
//    });
    
//    //********liuxu********
    
    [self startTiming];

    
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/index.html" withExtension:nil];
    
//    NSString *htmlPath = NSHomeDirectory();
//    htmlPath = [NSString stringWithFormat:@"%@/index.html", htmlPath];
//    // NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
//    [self.webView loadHTMLString:appHtml baseURL:baseURL];
    
//    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/json" withExtension:nil];
//    NSString *destPath = jsonURL.path;
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TFJCGS-TJ6-K" ofType:@"zip"];
//    // [SSZipArchive unzipFileAtPath:filePath toDestination:destPath];
//
//    [SSZipArchive unzipFileAtPath:filePath toDestination:destPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
//        int a = 0;
//    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
//        int b = 0;
//    }];
    
//    NSURL *localURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/index.html" withExtension:nil];
//    NSURLRequest *localRequest = [NSURLRequest requestWithURL:localURL];
//    [self.webView loadRequest:localRequest];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backRootNoti:) name:@"backRoot" object:nil];
}

- (void)backRootNoti:(NSNotification*)noti {
    NSNumber* index = [noti.userInfo objectForKey:@"index"];
    
    NSString *link = self.webView.request.URL.absoluteString;
    NSRange range = [link rangeOfString:@"/BimSiteApp/index?token="];
    if (0 == index.integerValue &&
        NSNotFound != range.location) {
        return;
    }
    
    if (index.integerValue == 0) {
        AppModel *appModel = [AppModel readModel];
        NSString* reqAddr = [NSString stringWithFormat:@"http://%@/BimSiteApp/index?token=%@",appModel.h5server, appModel.token];
        [self.webView loadUrl:reqAddr];
//        if (self.webView.canGoBack) {
//            [self.webView goBack];
//        }
    }
}

- (void)startTiming {
    if (self.timer) {
        return;
    }
    
    [self scheduledTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15*60 target:self selector:@selector(scheduledTimer) userInfo:nil repeats:YES];
}

- (void)scheduledTimer {
    AppModel *appModel = [AppModel readModel];
    [UserService todoCountWithToken:appModel.token andWidthServerAddress:appModel.wsserver widthFinish:^(LoginResultModel *model, NSString *result) {
        
        TodoModel *todo = (TodoModel *)model;
        if (todo) {
            if ([todo.StatusCode isEqualToString:@"S000"]) {
                NSInteger count = result.integerValue;
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSInteger preCount = [ud integerForKey:@"todoCount"];
                if (count > 0) {
                    BOOL toShow = NO;
                    if (!self.isFirst) {
                        self.isFirst = YES;
                        toShow = YES;
                    }else {
                        if (count != preCount) {
                            toShow = YES;
                        }
                    }
                    
                    if (toShow) {
                        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
                            [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
                        }
                        
                        [[UIApplication sharedApplication] cancelAllLocalNotifications];
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        notification.alertBody = [NSString stringWithFormat:@"您有%ld条待办任务！", count];
                        notification.userInfo = @{@"id": @1, @"type": @1};
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    }
                }
                
                [ud setInteger:count forKey:@"todoCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else {
                NSString *message = todo.StatusDesc;
                if (0 == message.length) {
                    message = @"登录已过期，请重新登录";
                }else {
                    message = [NSString stringWithFormat:@"%@ %@", message, @"请重新登录！"];
                }
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    AppModel *appModel = [AppModel readModel];
                    if (appModel) {
                        [UserService logoutWithToken:appModel.token andWidthServerAddress:appModel.wsserver];
                        [appModel logout];
                    }
                    [appDelegate logout];
                }]];
                [self presentViewController:alert animated:YES completion:NULL];
            }
        }
    }];
}

// 当UIWebView开始加载时激发该方法
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // 显示_activityIndicator控件
    _activityIndicator.hidden = NO;
    // 启动_activityIndicator控件的转动
    [_activityIndicator startAnimating] ;
}
// 当UIWebView加载完成时激发该方法
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 停止_activityIndicator控件的转动
    [_activityIndicator stopAnimating];
    // 隐藏_activityIndicator控件
    _activityIndicator.hidden = YES;
    AppModel *appModel = [AppModel readModel];
    if (appModel) {
        NSString* token = [NSString stringWithFormat:@"getUserToken('%@')", appModel.token];
        [self.webView stringByEvaluatingJavaScriptFromString:token];
        
        NSString* authorGroup = [NSString stringWithFormat:@"getAuthorGroup('%@')", appModel.authorGroup];
        [self.webView stringByEvaluatingJavaScriptFromString:authorGroup];
        
        NSString* userName = [NSString stringWithFormat:@"getUserName('%@')", appModel.userName];
        [self.webView stringByEvaluatingJavaScriptFromString:userName];
    }
    
    // javascript:openModel('json/WebGlTest/F3/F3.3gd.json','json/WebGlTest/F3/F3/')
    // TFJCGS-TJ6-K
    // NSString *js = [NSString stringWithFormat:@"openModel('%@', '%@')", @"json/WebGlTest/F3/F3.3gd.json", @"json/WebGlTest/F3/F3/"];
//    NSString *js = [NSString stringWithFormat:@"openModel('%@', '%@')", @"json/TFJCGS-TJ6-K/TFJCGS-TJ6-K.3gd.json", @"json/TFJCGS-TJ6-K/TFJCGS-TJ6-K/"];
//    [self.webView stringByEvaluatingJavaScriptFromString:js];
    
//    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Android_3DAir/json" withExtension:nil];
//    NSString *destPath = jsonURL.path;
//    destPath = [NSString stringWithFormat:@"%@/WebGlTest/TFJCGS-TJ6-K", destPath];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TFJCGS-TJ6-K" ofType:@"zip"];
//    // [SSZipArchive unzipFileAtPath:filePath toDestination:destPath];
//    
//    [SSZipArchive unzipFileAtPath:filePath toDestination:destPath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
//        int a = 0;
//    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
//        int b = 0;
//        NSString *js = [NSString stringWithFormat:@"openModel('%@', '%@')", @"json/WebGlTest/TFJCGS-TJ6-K/TFJCGS-TJ6-K.3gd.json", @"json/WebGlTest/TFJCGS-TJ6-K/TFJCGS-TJ6-K/"];
//        //NSString *js = [NSString stringWithFormat:@"openModel('%@', '%@')", @"json/WebGlTest/F3/F3.3gd.json", @"json/WebGlTest/F3/F3/"];
//        [self.webView stringByEvaluatingJavaScriptFromString:js];
//    }];
}
// 当UIWebView加载失败时激发该方法
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // 使用UIAlertView显示错误信息
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

- (void)downloadFileWidthUrl:(NSString *)Url andFileName:(NSString*)fileName {
    [[HSDownloadManager sharedInstance] download:Url andFileName:fileName progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"当前下载进度：%.2f%%", progress* 100);
        });
    } state:^(DownloadState state, NSError *error) {
        NSLog(@"state == %u", state);
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case DownloadStateStart:
                    return ;//@"暂停";
                case DownloadStateSuspended:
                case DownloadStateFailed:
                    return ;//@"开始";
                case DownloadStateCompleted:
                    NSLog(@"当前下载完成！");
                    
                    NSString* filePath = [[HSDownloadManager sharedInstance] fileFullPath:fileName];
                    //NSString* fileFullPath = [NSString stringWithFormat:@"setDownloadFileResult('%@')", filePath];
                    // [self.webView stringByEvaluatingJavaScriptFromString:fileFullPath];
                    [self performSelectorOnMainThread: @selector(setDownloadFileResult:) withObject: filePath waitUntilDone: NO];
                    return ;//@"完成";
            }
        });
    }];
    
}

-(void)setDownloadFileResult:(NSString*)fileFullPath
{
    NSString* resultContnet = [NSString stringWithFormat:@"setDownloadFileResult('%@')", fileFullPath];
    [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    
    /*NSData* data = [NSData dataWithContentsOfFile:fileFullPath];
    
    NSString* resultContnet = [NSString stringWithFormat:@"setDownloadFileResult('%@')", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    */
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

-(void)setWebQrcodeContent
{
    NSString* resultContnet = [NSString stringWithFormat:@"scanQrcodeResult('%@')", mQrcodeResult];
    [self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    
}

- (void)getNetworkState {
    NSInteger state = 0;
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        state = 1;
    }
    
    NSString *js = [NSString stringWithFormat:@"setNetworkState('%ld')", (long)state];
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)addBase64StrAndFileName:(NSArray *)params {
    if (4 != params.count) {
        return;
    }
    
    NSLog(@"存储图片: %@", params[1]);
    NSString *imgPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5img"];
    imgPath = [NSString stringWithFormat:@"%@/%@", imgPath, params[2]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:imgPath]) {
        [fileManager createDirectoryAtPath:imgPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }else {
        NSString *first = params[3];
        if ([first isEqualToString:@"true"]) {
            [fileManager removeItemAtPath:imgPath error:nil];
            [fileManager createDirectoryAtPath:imgPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    
    imgPath = [NSString stringWithFormat:@"%@/%ld%@", imgPath, (long)++gFileNum, params[1]];
    [fileManager createFileAtPath:imgPath contents:[params[0] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (void)getBase64Str:(NSString *)entryName {
    if (0 == entryName.length) {
        return;
    }
    
    NSString *imgPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5img"];
    imgPath = [NSString stringWithFormat:@"%@/%@", imgPath, entryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:imgPath error:nil];
    if (0 == files.count) {
        return;
    }
    
    for (NSString *fileName in files) {
        NSLog(@"发送图片: %@", fileName);
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", imgPath, fileName];
        NSString *fileContent = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        
        NSUInteger i = 0;
        NSUInteger size = 256; // 256;
        NSUInteger length = fileContent.length;
        for (i = 0; i < length; i += size) {
            @autoreleasepool {
                NSInteger len = size;
                if (i + size > length) {
                    len = length - i;
                }
                NSRange range = NSMakeRange(i, len);
                NSString *str = [fileContent substringWithRange:range];
                NSString *js = [NSString stringWithFormat:@"appendBase64Str('%@')", str];
                [self.webView stringByEvaluatingJavaScriptFromString:js];
            }
        }
        
        NSString *js = [NSString stringWithFormat:@"finishBase64Trans('%@')", fileName];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"原生提示" message:js delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"finishAllTrans()"];
    [fileManager removeItemAtPath:imgPath error:nil];
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
    
    //OC调用JS是基于协议拦截实现的 下面是相关操作
    NSString *absolutePath = request.URL.absoluteString;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:absolutePath delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
    
    NSString *scheme = @"rrcc://";
    
    if ([absolutePath hasPrefix:scheme]) {
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        
        if ([subPath hasPrefix:@"addBase64StrAndFileName"]) {
            NSString *methodStr = @"addBase64StrAndFileName";
            NSString *paramsStr = [subPath substringFromIndex:(methodStr.length + 1)];
            NSArray *paramsArr = [paramsStr componentsSeparatedByString:@"&"];
            methodStr = [NSString stringWithFormat:@"%@:", methodStr];
            SEL methodSel = NSSelectorFromString(methodStr);
            if ([self respondsToSelector:methodSel]) {
                [self performSelector:methodSel withObject:paramsArr];
            }
            
            return YES;
        }
        
        if ([subPath hasPrefix:@"getBase64Str"]) {
            NSString *methodStr = @"getBase64Str";
            NSString *paramsStr = [subPath substringFromIndex:(methodStr.length + 1)];
            
            methodStr = [NSString stringWithFormat:@"%@:", methodStr];
            SEL methodSel = NSSelectorFromString(methodStr);
            if ([self respondsToSelector:methodSel]) {
                [self performSelector:methodSel withObject:paramsStr];
            }
            
            return YES;
        }
        
        if ([subPath containsString:@"?"]) {//1个或多个参数
            
            if ([subPath containsString:@"&"]) {//多个参数
                NSArray *components = [subPath componentsSeparatedByString:@"?"];
                
                NSString *methodName = [components firstObject];
                
                methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
                SEL sel = NSSelectorFromString(methodName);
                
                NSString *parameter = [components lastObject];
                NSArray *params = [parameter componentsSeparatedByString:@"&"];
                
                if (params.count == 2) {
                    if ([self respondsToSelector:sel]) {
                        [self performSelector:sel withObject:[params firstObject] withObject:[params lastObject]];
                    }
                }
                
                
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
