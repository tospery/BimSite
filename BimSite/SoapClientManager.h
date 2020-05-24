//
//  SoapClientManager.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/26.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoapClientManager : NSObject

+(NSString*)createSoapXmlWidthActionName:(NSString*)actionName
                              andWidthActionParam:(NSString*)actionParam;

+(NSString*)createLoginSoapXmlWidthUserId:(NSString*)userId
                     andWidthPassword:(NSString*)password;

@end
