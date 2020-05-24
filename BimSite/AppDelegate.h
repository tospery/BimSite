//
//  AppDelegate.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/12.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>

extern NSInteger gFileNum;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

- (void)showTabController;
- (void)logout;
@end

