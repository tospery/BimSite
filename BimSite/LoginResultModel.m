//
//  LoginResult.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "LoginResultModel.h"
#import <objc/runtime.h>

@implementation LoginResultModel
+ (instancetype)modelWithDic:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        LoginResultModel *model = [LoginResultModel model];
        
        model.Status = [dictionary valueForKey:@"Status"];
        model.StatusCode = [dictionary valueForKey:@"StatusCode"];
        model.StatusDesc = [dictionary valueForKey:@"StatusDesc"];
        
        NSDictionary *data = [dictionary valueForKey:@"Result"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            //model.Result = [UserInfoModel model];
            UserInfoModel* tempModel = [UserInfoModel modelSmartWithDic:data];//[UserInfoModel modelWithDic:data];
            model.Result = tempModel;
            
        }
        return model;
    }
    
    return nil;
}
@end
