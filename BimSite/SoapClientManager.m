//
//  SoapClientManager.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/26.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "SoapClientManager.h"
#include "APPDefine.h"


@implementation SoapClientManager

+(NSString*)createSoapXmlWidthActionName:(NSString*)actionName
                     andWidthActionParam:(NSString*)actionParam
{
    NSString * soapXml = [NSString stringWithFormat:@"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\">\n"
                         "<s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n"
                            "<%@ xmlns=\"http://simu-tech.com/\">\n"
                                "%@\n"
                                "</%@>\n"
                            "</s:Body>\n"
                         "</s:Envelope>",
                         actionName,
                         actionParam,
                         actionName];

     return soapXml;
}

+(NSString*)createLoginSoapXmlWidthUserId:(NSString*)userId
                         andWidthPassword:(NSString*)password
{
    NSString* actionParam = [NSString stringWithFormat:@"<uId>%@</uId>\n"
                            "<password>%@</password>",
                            userId,
                            password];
    NSString* soapXml = [self createSoapXmlWidthActionName:@"AppLogin" andWidthActionParam:actionParam];
    return soapXml;
}

@end
