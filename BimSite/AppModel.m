//
//  AppModel.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/28.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "AppModel.h"
#include "APPDefine.h"

@implementation AppModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_isCurrentLogined forKey:@"isCurrentLogined"];
    [aCoder encodeBool:_isRemembered forKey:@"isRemembered"];
    [aCoder encodeBool:_isAutoLogined forKey:@"isAutoLogined"];
    [aCoder encodeObject:_phone forKey:@"phone"];
    [aCoder encodeObject:_passwd forKey:@"passwd"];
    [aCoder encodeObject:_token forKey:@"token"];
    [aCoder encodeObject:_userinfo forKey:@"userinfo"];
    [aCoder encodeObject:_wsserver forKey:@"wsserver"];
    [aCoder encodeObject:_h5server forKey:@"h5server"];
    [aCoder encodeObject:_authorGroup forKey:@"authorGroup"];
    [aCoder encodeObject:_userImage forKey:@"userImage"];
    [aCoder encodeObject:_userName forKey:@"userName"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init]) {
        self.isCurrentLogined   = [aDecoder decodeBoolForKey:@"isCurrentLogined"];
        self.isRemembered   = [aDecoder decodeBoolForKey:@"isRemembered"];
        self.isAutoLogined  = [aDecoder decodeBoolForKey:@"isAutoLogined"];
        self.phone  = [aDecoder decodeObjectForKey:@"phone"];
        self.passwd = [aDecoder decodeObjectForKey:@"passwd"];
        self.token  = [aDecoder decodeObjectForKey:@"token"];
        self.userinfo = [aDecoder decodeObjectForKey:@"userinfo"];
        self.wsserver = [aDecoder decodeObjectForKey:@"wsserver"];
        self.h5server = [aDecoder decodeObjectForKey:@"h5server"];
        self.authorGroup = [aDecoder decodeObjectForKey:@"authorGroup"];
        self.userImage = [aDecoder decodeObjectForKey:@"userImage"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];

    }
    return self;
}

+ (BOOL)isNeedLogin
{
    AppModel *model = [AppModel readModel];
    if (model && model.isAutoLogined && model.token) {
        return NO;
    }
    return YES;
}
+ (AppModel*)readModel
{
//    if (GETUSERDEFAULT(CACHEKEY_APPDATA)) {
//        NSData *data = GETUSERDEFAULT(CACHEKEY_APPDATA);
//        AppModel* model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        return model;
//    }
//    return nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    
    AppModel *model = nil;
    for (NSString *key in dict.allKeys) {
        NSData *data = [dict objectForKey:key];
        AppModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (m.isCurrentLogined) {
            model = m;
            break;
        }
    }
    
    return model;
}

+ (AppModel*)readPrevModel
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    
    AppModel *model = nil;
    for (NSString *key in dict.allKeys) {
        NSData *data = [dict objectForKey:key];
        AppModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (m.isRemembered) {
            model = m;
            break;
        }
    }
    
    return model;
}

- (void)saveModel
{
//    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    SETUSERDEFAULT(CACHEKEY_APPDATA, data);
//    SAVEUSERDEFAULT;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    //NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    
    NSString *ws = [ud objectForKey:@"BS_WS"];
    NSString *h5 = [ud objectForKey:@"BS_H5"];
    if ([ws isEqualToString:self.wsserver] &&
        [h5 isEqualToString:self.h5server]) {
        for (NSString *key in dict.allKeys) {
            NSData *data = [dict objectForKey:key];
            AppModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            m.isRemembered = NO;
            m.isCurrentLogined = NO;
            data = [NSKeyedArchiver archivedDataWithRootObject:m];
            [mdict setObject:data forKey:m.phone];
        }
    }else {
        [mdict removeAllObjects];
    }
    [ud setObject:self.wsserver forKey:@"BS_WS"];
    [ud setObject:self.h5server forKey:@"BS_H5"];
    
    self.isRemembered = YES;
    self.isCurrentLogined = YES;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [mdict setObject:data forKey:self.phone];
    [ud setObject:mdict forKey:@"BSUsers"];
    
    SAVEUSERDEFAULT;
}

- (void)logout {
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
//
//    AppModel *model = nil;
//    for (NSString *key in dict.allKeys) {
//        NSData *data = [dict objectForKey:key];
//        model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        if (model.isCurrentLogined) {
//            break;
//        }
//    }
//
//    return model;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
    
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    for (NSString *key in dict.allKeys) {
        NSData *data = [dict objectForKey:key];
        AppModel *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        m.isRemembered = NO;
        m.isCurrentLogined = NO;
        data = [NSKeyedArchiver archivedDataWithRootObject:m];
        [mdict setObject:data forKey:m.phone];
    }
    
    self.isRemembered = YES;
    self.isCurrentLogined = NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [mdict setObject:data forKey:self.phone];
    [ud setObject:mdict forKey:@"BSUsers"];
    
    SAVEUSERDEFAULT;
}

//- (void)my_saveModel {
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dict = [ud dictionaryForKey:@"BSUsers"];
//    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
//    
//    self.isCurrentLogined = YES;
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    [mdict setObject:data forKey:self.phone];
//    
//    SAVEUSERDEFAULT;
//}

- (void)clearModelWhenLogout
{
    self.isCurrentLogined = NO;
    
    self.isAutoLogined = NO;
    self.isRemembered   = nil;
    //self.phone  = nil;
    //self.passwd  = nil;
    //self.wsserver = nil;
    //self.authorGroup  = nil;
    self.userImage  = nil;
    [self saveModel];
}@end
