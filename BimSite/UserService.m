//
//  BaseService.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/31.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "UserService.h"
#import "APPDefine.h"
#import "AFHTTPSessionManager.h"
#import "SoapClientManager.h"
#import "XMLDictionary.h"
#import "SoapClientManager.h"
#import <MJExtension/MJExtension.h>
#import "TodoModel.h"

@implementation UserService

+ (void)loginWithUserName:(NSString*)uid andWithPassword:(NSString*)pwd andWidthServerAddress: (NSString*)wsserver widthFinish:(void(^)(LoginResultModel *model, NSString* result))finish
{
    NSString* actionParam = [NSString stringWithFormat:@"<uId>%@</uId>\n"
                             "<password>%@</password>",
                             uid,
                             pwd];
    NSString* soapMessage = [SoapClientManager createSoapXmlWidthActionName:@"AppLogin" andWidthActionParam:actionParam];
    NSString *Url =[NSString stringWithFormat:@"http://%@/SimuBimSiteApp/BIMSiteService.asmx",wsserver];
    [UserService requestWithSoapmessage:soapMessage andWidthUrl:Url andWidthMethod:@"AppLogin" andWidthFinish:finish apiTag:0];
}

// http://182.150.20.168:8111/SimuBimSiteApp/BIMSiteService.asmx?op=APPGetToDoItemCount
+ (void)todoCountWithToken:(NSString*)token andWidthServerAddress: (NSString*)wsserver widthFinish:(void(^)(LoginResultModel *model, NSString* result))finish {
    NSString* actionParam = [NSString stringWithFormat:@"<token>%@</token>\n",token];
    NSString* soapMessage = [SoapClientManager createSoapXmlWidthActionName:@"APPGetToDoItemCount" andWidthActionParam:actionParam];
    NSString *Url =[NSString stringWithFormat:@"http://%@/SimuBimSiteApp/BIMSiteService.asmx",wsserver];
    
    [UserService requestWithSoapmessage:soapMessage andWidthUrl:Url andWidthMethod:@"APPGetToDoItemCount" andWidthFinish:finish apiTag:1];
}

+ (void)logoutWithToken:(NSString*)token andWidthServerAddress: (NSString*)wsserver {
    NSString* actionParam = [NSString stringWithFormat:@"<token>%@</token>\n",token];
    NSString* soapMessage = [SoapClientManager createSoapXmlWidthActionName:@"AppLogout" andWidthActionParam:actionParam];
    NSString *Url =[NSString stringWithFormat:@"http://%@/SimuBimSiteApp/BIMSiteService.asmx",wsserver];
    
    [UserService requestWithSoapmessage:soapMessage andWidthUrl:Url andWidthMethod:@"AppLogout" andWidthFinish:nil apiTag:0];
}

+ (void)requestWithSoapmessage:(NSString*)soapMessage andWidthUrl:(NSString*)Url andWidthMethod:(NSString*)method andWidthFinish:(void(^)(LoginResultModel *model, NSString* result))finish apiTag:(NSInteger)apiTag
{
    static LoginResultModel *tempModel = nil;
    NSString *soapLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"application/soap+xml;charset=utf-8;action=\"http://www.Simu-Tech.com/%@\"",method] forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:soapLength forHTTPHeaderField:@"Content-Length"];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.0f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/soap+xml", @"text/xml", @"text/javascript",@"text/html", nil, nil];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:Url parameters:nil error:nil];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:
                                  ^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
                                      if(!error)
                                      {
                                          //XMLDictionaryParser解析
                                          XMLDictionaryParser *parser = [XMLDictionaryParser sharedInstance];
                                          NSDictionary *data = [parser dictionaryWithParser:responseObject];
                                          //需要的内容
                                          NSDictionary *dic = [data valueForKey:@"soap:Body"];
                                          if (apiTag == 0) {
                                              NSDictionary *loginResponse = [dic valueForKey:@"AppLoginResponse"];
                                              if(loginResponse == nil)
                                                  return ;
                                              
                                              NSString *loginResult = [loginResponse valueForKey:@"AppLoginResult"];
                                              NSLog(@"Data:\n%@",loginResult);
                                              
                                              NSDictionary *logInfo = [UserService dictionaryWithJsonString:loginResult];
                                              tempModel = [LoginResultModel modelWithDic:logInfo];
                                              tempModel.responseString = loginResult;
                                              if (finish) {
                                                  finish(tempModel, tempModel.Result == nil ? @"" : [self convertToJSONData:[logInfo valueForKey:@"Result"]]);
                                              }
                                          }else if (apiTag == 1) {
                                              NSDictionary *todoResponse = [dic valueForKey:@"APPGetToDoItemCountResponse"];
                                              if(todoResponse == nil)
                                                  return ;
                                              
                                              NSString *todoResult = [todoResponse valueForKey:@"APPGetToDoItemCountResult"];
                                              NSLog(@"Data:\n%@",todoResult);
                                              TodoModel *todo = [TodoModel mj_objectWithKeyValues:todoResult];
                                              NSInteger count = 0;
                                              for (TodoModelResult *r in todo.Result) {
                                                  count += r.Count;
                                              }
                                              if (finish) {
                                                  finish(todo,  [NSString stringWithFormat:@"%ld", (long)count]);
                                              }
                                          }

                                      }
                                      else
                                      {
                                          if (finish) {
                                              finish(nil, @"");
                                          }
                                      }
                                  }];
    [task resume];
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
        
    }
    return dic;
    
}

+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = @"";
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonString;
}

@end
