//
//  AppModel.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/28.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "BaseModel.h"

@interface AppModel : BaseModel
@property (nonatomic , assign) BOOL isCurrentLogined;

@property (nonatomic , assign) BOOL isRemembered;
@property (nonatomic , assign) BOOL isAutoLogined;
@property (nonatomic , strong) NSString *phone;
@property (nonatomic , strong) NSString *passwd;
@property (nonatomic , strong) NSString *userName;


@property (nonatomic , copy) NSString *token;
@property (nonatomic , copy) NSString *userinfo;
@property (nonatomic , copy) NSString *wsserver;
@property (nonatomic , copy) NSString *h5server;
@property (nonatomic , copy) NSString *authorGroup;
@property (nonatomic , copy) NSString *userImage;

+ (BOOL)isNeedLogin;
+ (AppModel*)readModel;
+ (AppModel*)readPrevModel;
- (void)saveModel;
- (void)logout;

- (void)clearModelWhenLogout;

@end
