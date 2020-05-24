//
//  BaseService.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/31.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginResultModel.h"

@interface UserService : NSObject

+ (void)loginWithUserName:(NSString*)uid andWithPassword:(NSString*)pwd andWidthServerAddress: (NSString*)wsserver widthFinish:(void(^)(LoginResultModel *model, NSString* result))finish;
+ (void)logoutWithToken:(NSString*)token andWidthServerAddress: (NSString*)wsserver;

+ (void)requestWithSoapmessage:(NSString*)soapMessage andWidthUrl:(NSString*)Url andWidthMethod:(NSString*)method andWidthFinish:(void(^)(LoginResultModel *model, NSString* result))finish apiTag:(NSInteger)apiTag;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)convertToJSONData:(id)infoDict;


+ (void)todoCountWithToken:(NSString*)token andWidthServerAddress: (NSString*)wsserver widthFinish:(void(^)(LoginResultModel *model, NSString* result))finish;

@end
