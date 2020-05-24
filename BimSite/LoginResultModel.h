//
//  LoginResult.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "ResultModel.h"
#import "UserInfoModel.h"

@interface LoginResultModel : ResultModel

@property (nonatomic , strong) UserInfoModel *Result;
@end
