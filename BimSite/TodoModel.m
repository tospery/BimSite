//
//  TodoModel.m
//  BimSite
//
//  Created by 杨建祥 on 2017/9/24.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "TodoModel.h"
#import <MJExtension/MJExtension.h>

@implementation TodoModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"Result": [TodoModelResult class]};
}

@end


@implementation TodoModelResult

@end
