//
//  StateMode.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface ResultModel : BaseModel
@property (nonatomic , copy) NSString *Status;
@property (nonatomic , copy) NSString *StatusCode;
@property (nonatomic , copy) NSString *StatusDesc;
@property (nonatomic , copy) NSString *responseString;

@end
