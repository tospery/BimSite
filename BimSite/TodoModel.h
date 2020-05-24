//
//  TodoModel.h
//  BimSite
//
//  Created by 杨建祥 on 2017/9/24.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoModel : NSObject
@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *StatusCode;
@property (nonatomic, copy) NSString *StatusDesc;
@property (nonatomic, copy) NSString *ColList;
@property (nonatomic, strong) NSArray *Result;


@end


@interface TodoModelResult : NSObject
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *Key;
@property (nonatomic, copy) NSString *Value;

@end
