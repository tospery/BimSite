//
//  UserInfo.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface UserInfoModel : BaseModel

@property (nonatomic , copy) NSString *Token;
@property (nonatomic , copy) NSString *UserNo;
@property (nonatomic , copy) NSString *UserName;
@property (nonatomic , copy) NSString *Department;
@property (nonatomic , copy) NSString *Telephone;
@property (nonatomic , copy) NSString *Cell;
@property (nonatomic , copy) NSString *UserImage;
@property (nonatomic , copy) NSString *AuthorGroup;
@end

