//
//  CommonWebViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/22.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "CommonWebViewController.h"
#import "AppModel.h"
#include "APPDefine.h"
#import "UserService.h"
#import "HSDownloadManager.h"
#import "QrcodeViewController.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "ChangeUserSendData.h"
#import <MJExtension/MJExtension.h>
#import "UIWebView+BSWebView.h"
#import <CocoaSecurity/Base64.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UserInfo.h"
#import "AppDelegate.h"
#import "UIColor+BSUIColor.h"

NSInteger jsTag = 0;

@interface CommonWebViewController ()
@property (nonatomic, strong) NSURL *retryURL;
@property (nonatomic, strong) UIView *errorView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CommonWebViewController
@synthesize mH5Url;
@synthesize mQrcodeResult;

UIActivityIndicatorView* _webActivityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.scalesPageToFit = NO;
    // 为UIWebView控件设置委托
    self.webView.delegate = self;
    // 创建一个UIActivityIndicatorView控件
    _webActivityIndicator = [[UIActivityIndicatorView alloc]
                          initWithFrame : CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    // 控制UIActivityIndicatorView显示在当前View的中央
    [_webActivityIndicator setCenter: self.view.center];
    _webActivityIndicator.activityIndicatorViewStyle
    = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview : _webActivityIndicator];
    // 隐藏_activityIndicator控件
    _webActivityIndicator.hidden = YES;
    
    NSString* reqAddr = mH5Url;
    NSRange range = [reqAddr rangeOfString:@"/person/accountManager"];
    
    //[self.webView loadUrl:reqAddr];
    
    if(range.length > 0){
        AppModel *appModel = [AppModel readModel];
        NSString *body = [NSString stringWithFormat: @"json=%@", appModel.userinfo];
        //body = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //body = [body stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        body = [body stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%<>[\\]^`{|}\"]+"].invertedSet];
        
//        NSMutableString *mutStr = [NSMutableString stringWithString:body];
//        NSRange range = {0,body.length};
//        NSRange range2 = {0,mutStr.length};
//        [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:range2];
        
        NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
            policy = NSURLRequestReloadIgnoringLocalCacheData;
        }
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:reqAddr] cachePolicy:policy timeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
         [self.webView loadRequest:request];
        
//        UserInfo *gUser = [UserInfo mj_objectWithKeyValues:appModel.userinfo];
//        
//        NSString *userNo = gUser.userNo; // JXStrWithDft(gUser.userNo, @"空");
//        if (0 == userNo.length) {
//            userNo = @"";
//        }
//        NSString *userImage = appModel.userImage; // JXStrWithDft(gUser.UserImage, @"");
//        if (0 == userImage.length) {
//            userImage = @"";
//        }
//        NSString *userName = appModel.userName; // JXStrWithDft(gUser.UserName, @"空");
//        if (0 == userName.length) {
//            userName = @"空";
//        }
//        NSString *department = gUser.department; // JXStrWithDft(gUser.Department, @"空");
//        if (0 == department.length) {
//            department = @"空";
//        }
//        NSString *telephone = gUser.telephone; // JXStrWithDft(gUser.Telephone, @"空");
//        if (0 == telephone.length) {
//            telephone = @"空";
//        }
//        NSString *cell = gUser.cell; //  JXStrWithDft(gUser.Cell, @"空");
//        if (0 == cell.length) {
//            cell = @"空";
//        }
//        NSString *authorGroup = appModel.authorGroup; // JXStrWithInt(gUser.AuthorGroup);
//        if (0 == authorGroup.length) {
//            authorGroup = @"0";
//        }
//        
//        NSString *query = [NSString stringWithFormat:@"json={\"token\": \"%@\", \"userImage\": \"%@\", \"userNo\": \"%@\", \"userName\": \"%@\", \"department\": \"%@\", \"telephone\": \"%@\", \"cell\": \"%@\", \"authorGroup\": \"%@\"}", appModel.token, userImage, userNo, userName, department, telephone, cell, authorGroup];
//        reqAddr = [NSString stringWithFormat:@"%@?%@", reqAddr, query];
//        
//        NSString *uniStr = [NSString stringWithUTF8String:reqAddr.UTF8String];
//        NSData *uniData = [uniStr dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//        reqAddr = [[NSString alloc] initWithData:uniData encoding:NSUTF8StringEncoding];
//        
//        reqAddr = [reqAddr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        
//        [self.webView loadUrl:reqAddr];
//        int a = 0;
    }
    else
    {
        //NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqAddr]];
        
//        NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
//        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
//            policy = NSURLRequestReloadIgnoringLocalCacheData;
//        }
//        
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:reqAddr] cachePolicy:policy timeoutInterval:30];
//        // 加载指定URL对应的网址
//        [self.webView loadRequest:request];
        
        //********liuxu********
        [self.webView loadUrl:reqAddr];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// 当UIWebView开始加载时激发该方法
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // 显示_activityIndicator控件
    _webActivityIndicator.hidden = NO;
    // 启动_activityIndicator控件的转动
    [_webActivityIndicator startAnimating] ;
    
    if (self.errorView.tag == 101) {
        self.errorView.tag = 0;
        [self.errorView removeFromSuperview];
    }
}
// 当UIWebView加载完成时激发该方法
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 停止_activityIndicator控件的转动
    [_webActivityIndicator stopAnimating];
    // 隐藏_activityIndicator控件
    _webActivityIndicator.hidden = YES;
    
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
    
    NSString *absoluteString = webView.request.URL.absoluteString;
    if ([absoluteString hasSuffix:@"/switchAccount.jsp"]) {
//        AppModel *am = [AppModel readModel];
//        ChangeUserSendData *user = [ChangeUserSendData new];
//        user.name = am.phone;
//        user.loginName = am.userName;
//
//        ChangeUserSendDataArr *list = [ChangeUserSendDataArr new];
//        list.users = @[user];
//        
//        NSString *jsonString = [list mj_JSONString];
//        if (jsonString.length > 10) {
//            NSRange range = NSMakeRange(9, jsonString.length - 10);
//            jsonString = [jsonString substringWithRange:range];
//        }
//        jsonString = [jsonString base64EncodedString];
//        
//        NSString *jsString = [NSString stringWithFormat:@"setUserListJSON('%@','%@')", jsonString, appModel.userName];
//        [self.webView stringByEvaluatingJavaScriptFromString:jsString];
        
        
        [self syncUserList];
    }
    
    //[self.webView stringByEvaluatingJavaScriptFromString:@"getUserInfo('userinfo----test')"];
    
}

- (void)syncUserList {
    NSMutableArray *userObjs = [NSMutableArray arrayWithCapacity:20];
    AppModel *current = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    for (NSString *key in dict.allKeys) {
        NSData *data = [dict objectForKey:key];
        AppModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [userObjs addObject:model];
        if (model.isCurrentLogined) {
            current = model;
        }
    }
    
    NSMutableArray *userReqs = [NSMutableArray arrayWithCapacity:20];
    for (AppModel *am in userObjs) {
        ChangeUserSendData *user = [ChangeUserSendData new];
        user.name = am.userName;
        user.loginName = am.phone;
        [userReqs addObject:user];
    }
    
    ChangeUserSendDataArr *list = [ChangeUserSendDataArr new];
    list.users = userReqs;
    
    NSString *jsonString = [list mj_JSONString];
    if (jsonString.length > 10) {
        NSRange range = NSMakeRange(9, jsonString.length - 10);
        jsonString = [jsonString substringWithRange:range];
    }
    jsonString = [jsonString base64EncodedString];
    
    NSString *jsString = [NSString stringWithFormat:@"setUserListJSON('%@','%@')", jsonString, current.phone];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

// 当UIWebView加载失败时激发该方法
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // 停止_activityIndicator控件的转动
    [_webActivityIndicator stopAnimating];
    // 隐藏_activityIndicator控件
    _webActivityIndicator.hidden = YES;
    
    
    NSLog(@"bbb: code = %ld, reason = %@", error.code, error.localizedDescription);
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
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.adjustsImageWhenHighlighted = NO;
            [backBtn setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(backWhenErrorPressed:) forControlEvents:UIControlEventTouchUpInside];
            [backBtn sizeToFit];
            [navView addSubview:backBtn];
            backBtn.center = navView.center;
            backBtn.frame = CGRectMake(8, backBtn.frame.origin.y, backBtn.frame.size.width, backBtn.frame.size.height);
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

- (void)showMsg:(NSString *)msg {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    /*
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];*/
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
    }];
    
    //[alertController addAction:cancelAction];
    [alertController addAction:otherAction];

    [self presentViewController:alertController animated:YES completion:nil];
    
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
    NSData* data = [NSData dataWithContentsOfFile:fileFullPath];
    
    //NSString* resultContnet = [NSString stringWithFormat:@"setDownloadFileResult('%@')", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    //[self.webView stringByEvaluatingJavaScriptFromString:resultContnet];
    
}

- (void)finishViewWidthData1AndData2:(NSString *)data1 data2:(NSString *)data2 {
    NSString *info = [NSString stringWithFormat:@"这是js传过来的参数1: %@, 参数2%@ ",data1,data2];
    
    [self showMsg:info];
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
    
//    id a = request.allHTTPHeaderFields;
//    NSData *b = request.HTTPBody;
//    NSString *c = [[NSString alloc] initWithData:b encoding:NSUTF8StringEncoding];
    
//    NSURLRequestCachePolicy policy = NSURLRequestReturnCacheDataElseLoad;
//    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
//        policy = NSURLRequestReloadIgnoringLocalCacheData;
//    }
//    request.cachePolicy = policy;
    
    //OC调用JS是基于协议拦截实现的 下面是相关操作
    self.retryURL = request.URL;
    
    NSString *absolutePath = request.URL.absoluteString;
    
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
                if ([methodName isEqualToString:@"setCurrentUser"]) {
                    methodName = [NSString stringWithFormat:@"%@:", methodName];
                }else if ([methodName isEqualToString:@"deleteUser"]) {
                    methodName = [NSString stringWithFormat:@"%@:", methodName];
                }
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

- (void)setCurrentUser:(NSString *)name {
//    NSString *bbb = [name base64DecodedString];
//    NSString *userName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)name, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    
    AppModel *am = [AppModel readModel];
    if (am) {
        [UserService logoutWithToken:am.token andWidthServerAddress:am.wsserver];
        [am logout];
    }
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    NSData *data = [dict objectForKey:name];
    am = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
//    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//    
//    self.isCurrentLogined = YES;
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    [mdict setObject:data forKey:self.phone];
//    [ud setObject:mdict forKey:@"BSUsers"];
//    
//    SAVEUSERDEFAULT;
    
    [SVProgressHUD show];
    [UserService loginWithUserName:am.phone andWithPassword:am.passwd andWidthServerAddress:am.wsserver widthFinish:^(LoginResultModel *model, NSString* result) {
        if(model == nil){
            AppModel *appModel = [AppModel readModel];
            if(appModel != nil){
                if([appModel.phone isEqualToString:am.phone] && [appModel.passwd isEqualToString:am.passwd] && [appModel.wsserver isEqualToString:am.wsserver]){
                    [SVProgressHUD dismiss];
                    [appDelegate showTabController];//成功的处理
                }
                else{
                    [SVProgressHUD showErrorWithStatus:@"登录失败:服务器错误！"];
                }
            }
            else{
                [SVProgressHUD showErrorWithStatus:@"登录失败:服务器错误！"];
            }
        }else if([model.StatusCode isEqualToString:@"S000"]){
            AppModel *appModel = [[AppModel alloc]init];
            appModel.phone = am.phone;
            appModel.passwd = am.passwd;
            appModel.isRemembered = NO;
            appModel.isAutoLogined = YES;
            
            result=[result stringByReplacingOccurrencesOfString:@"Token"withString:@"token"];
            result=[result stringByReplacingOccurrencesOfString:@"UserNo"withString:@"userNo"];
            result=[result stringByReplacingOccurrencesOfString:@"Telephone"withString:@"telephone"];
            result=[result stringByReplacingOccurrencesOfString:@"Cell"withString:@"cell"];
            result=[result stringByReplacingOccurrencesOfString:@"UserImage"withString:@"authorGroup"];
            result=[result stringByReplacingOccurrencesOfString:@"AuthorGroup"withString:@"cell"];
            result=[result stringByReplacingOccurrencesOfString:@"UserName"withString:@"userName"];
            result=[result stringByReplacingOccurrencesOfString:@"Department"withString:@"department"];
            
            appModel.userinfo = model.responseString; //  result;//[LoginViewController convertToJSONData:model.Result];
            appModel.wsserver = am.wsserver;
            appModel.h5server = am.h5server;
            appModel.token    = model.Result.Token;
            appModel.userName = model.Result.UserName;
            appModel.authorGroup = model.Result.AuthorGroup;
            appModel.userImage = model.Result.UserImage;
            [appModel saveModel];
            [SVProgressHUD dismiss];
            
            //end
            [appDelegate showTabController];//成功的处理
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"登录失败:%@", model.StatusDesc]];
        }
    }];
}

- (void)loginToAdd {
    AppModel *appModel = [AppModel readModel];
    if (appModel) {
        [UserService logoutWithToken:appModel.token andWidthServerAddress:appModel.wsserver];
        [appModel logout];
        //        appModel.token = nil;
        //        [appModel saveModel];
    }
    [appDelegate logout];//成功的处理
}

- (void)deleteUser:(NSString *)name {
    if (name.length == 0) {
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mdict removeObjectForKey:name];
    [ud setObject:mdict forKey:@"BSUsers"];
    SAVEUSERDEFAULT;
    
    [self syncUserList];
    
//    NSString *message = [NSString stringWithFormat:@"是否确认删除%@账户", name];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
//        NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//        [mdict removeObjectForKey:name];
//        [ud setObject:mdict forKey:@"BSUsers"];
//        SAVEUSERDEFAULT;
//        
//         [self syncUserList];
//    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }]];
//    [self presentViewController:alert animated:YES completion:NULL];
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
    
//    NSString *msg = [NSString stringWithFormat:@"addBase64StrAndFileName: %@", params[1]];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"原生提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
    
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
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"finishAllTrans()"];
    [fileManager removeItemAtPath:imgPath error:nil];
}

@end







