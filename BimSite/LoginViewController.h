//
//  LoginViewController.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/14.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSString*)convertToJSONData:(id)infoDict;
@end
