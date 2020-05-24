//
//  ChangeUserSendData.h
//  BimSite
//
//  Created by 杨建祥 on 2017/9/24.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangeUserSendData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *loginName;

@end

@interface ChangeUserSendDataArr : NSObject
@property (nonatomic, strong) NSArray *users;

@end
