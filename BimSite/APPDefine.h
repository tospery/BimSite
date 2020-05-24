//
//  APPDefine.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/15.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//
 
#ifndef APPDefine_h
#define APPDefine_h

#import "AppDelegate.h"

#define H5_SERVER_ADDRESS      @"139.199.206.175:80" // @"172.16.0.137:8080" // @"139.199.206.175:80" // @"172.16.0.137:8080" // @"139.199.206.175:80"
#define WS_SERVER_ADDRESS      @"182.150.20.168:8111"
//*******************************************************//
#pragma mark - System Define
#define appDelegate   ((AppDelegate *)[[UIApplication sharedApplication] delegate])


#pragma mark soap xml define
#define soapEnvelope        @"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\">";
#define soapEnvelopeEnd     @"</s:Envelope>";
#define soapBody            @"<s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">";
#define soapBodyEnd         @"</s:Body>";

#define CACHEKEY_APPDATA                @"cachekey_appdata"
#define CACHEKEY_USER                   @"cachekey_user"


#pragma mark data easy

#define MyLocal(x, ...) NSLocalizedString(x, nil)
#define SETUSERDEFAULT(k,v) [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]
#define SAVEUSERDEFAULT     [[NSUserDefaults standardUserDefaults]synchronize]
#define GETUSERDEFAULT(k) [[NSUserDefaults standardUserDefaults] objectForKey:k]
#define REMOVEUSERDEFAULT(k) [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]
#define WeakSelf(class) __weak typeof(class) weakSelf = class

#endif /* APPDefine_h */
