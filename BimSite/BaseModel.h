//
//  BaseModel.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
@property (nonatomic, copy) NSString *objectId;

+ (instancetype)model;
+ (instancetype)modelWithDic:(NSDictionary *)dictionary;
- (instancetype)initWithDic:(NSDictionary *)dictionary;

+ (instancetype)modelSmartWithDic:(NSDictionary *)dictionary;
- (instancetype)initSmartWithDic:(NSDictionary *)dictionary;
@end
