//
//  AppDelegate.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/12.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+BSUIColor.h"
#import "GLCustomURLCache.h"
#import "AppModel.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>
#import "BSIPhoneViewController.h"
#import "JXCacheURLProtocol.h"
#import "CustomURLCache.h"
#import "HomeViewController.h"
#import <SSZipArchive/SSZipArchive.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>

//#import <PgySDK/PgyManager.h>
//#import <PgyUpdate/PgyUpdateManager.h>
#import <Bugly/Bugly.h>

NSInteger gFileNum;

@interface AppDelegate () <UNUserNotificationCenterDelegate, UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        if (!error) {
//            NSLog(@"request authorization succeeded!");
//        }
//    }];
//
//    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//        NSLog(@"%@",settings);
//    }];
//
//    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        NSLog(@"%@",granted ? @"相机准许":@"相机不准许");
    }];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"用户已同意通知许可");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                }];
            }else {
                NSLog(@"用户未同意通知许可");
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
//    [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"网络已断开，请联网后继续下载" cancelButtonTitle:@"继续下载" otherButtonTitles:@[@"取消下载"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        int a = 0;
//    }];
    
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.alertTitle = @"新消息";
//    notification.alertBody = @"本地通知测试";
//    notification.userInfo = @{@"id": @1, @"type": @1};
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [Bugly startWithAppId:@"8376cfa241" /*@"3107bf42ce"*/];
    
//    [[PgyManager sharedPgyManager] setEnableDebugLog:NO];
//    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
//    [[PgyManager sharedPgyManager] startManagerWithAppId:@"8722b8faf9350346399bcd3fa3a15910"];
//    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"8722b8faf9350346399bcd3fa3a15910"];
//    [[PgyUpdateManager sharedPgyManager] checkUpdate];
    
    // [GLCustomURLCache configCache];
    
//        CustomURLCache *urlCache = [[CustomURLCache alloc] initWithMemoryCapacity:256 * 1024 * 1024
//                                                                     diskCapacity:512 * 1024 * 1024
//                                                                         diskPath:nil
//                                                                        cacheTime:0];
//        [CustomURLCache setSharedURLCache:urlCache];
    
    [NSURLProtocol registerClass:[JXCacheURLProtocol class]];
    [JXCacheURLProtocol setCachingEnabled:YES];
    
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *preVersion = [ud objectForKey:@"BimSiteVersion"];
    NSString *curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    
    NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"Android_3DAir" ofType:@"zip"];
    NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5loc"];
    
    NSString *htmlPath = [NSString stringWithFormat:@"%@/Android_3DAir/model3D.html", pagePath];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isNeedUnzip = NO;
    if ([fm fileExistsAtPath:htmlPath]) {
        if (![curVersion isEqualToString:preVersion] &&
            [curVersion isEqualToString:@"1.1.0"]) {
            [fm removeItemAtPath:pagePath error:nil];
            isNeedUnzip = YES;
        }
    }else {
        isNeedUnzip = YES;
    }
    
    if (isNeedUnzip) {
        [SSZipArchive unzipFileAtPath:zipPath toDestination:pagePath overwrite:YES password:nil progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            NSLog(@"本地html解压成功！！！");
        }];
    }
    
    [ud setObject:curVersion forKey:@"BimSiteVersion"];
    [ud synchronize];
    
    [self showRoot];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"1" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alert show];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"2" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"3" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%@", NSHomeDirectory());
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification");
//    if ([[notification.userInfo objectForKey:@"id"] isEqualToString:LOCAL_NOTIFY_SCHEDULE_ID]) {
//        　　//判断应用程序当前的运行状态，如果是激活状态，则进行提醒，否则不提醒
//        　　if (application.applicationState == UIApplicationStateActive) {
//            　　 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:notification.alertBody delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
//            　 [alert show];
//            　　}
//        　　}
    if ([[notification.userInfo objectForKey:@"id"] integerValue] == 1) {
        if (application.applicationState == UIApplicationStateActive) {
            if (0 != notification.alertBody.length) {
                NSString *title = @"提示";
                if ([UIDevice currentDevice].systemVersion.floatValue >= 8.2) {
                    if (0 != notification.alertTitle.length) {
                        title = notification.alertTitle;
                    }
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:notification.alertBody delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
        }else {
            NSLog(@"ios < 10，后台点击通知！！！");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = self.window.rootViewController;
                if ([vc isKindOfClass:[BSIPhoneViewController class]]) {
                    BSIPhoneViewController *tb = (BSIPhoneViewController *)vc;
                    HomeViewController *home = (HomeViewController *)tb.viewControllers.firstObject;
                    [home goWork];
                }
            });
        }
    }
}

// 前台接收
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"willPresentNotification");
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"远程通知1");
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"10" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
    }else {
        NSLog(@"本地通知1");
//        if ([[notification.request.content.userInfo objectForKey:@"id"] integerValue] == 1) {
//            if (0 != notification.request.content.body) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:notification.request.content.body delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }
    }
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.

// 后台进入
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    NSLog(@"didReceiveNotificationResponse");
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"远程通知2");
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"20" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
    }else {
        NSLog(@"本地通知2");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *vc = self.window.rootViewController;
            if ([vc isKindOfClass:[BSIPhoneViewController class]]) {
                BSIPhoneViewController *tb = (BSIPhoneViewController *)vc;
                HomeViewController *home = (HomeViewController *)tb.viewControllers.firstObject;
                [home goWork];
            }
        });

//        if ([[response.notification.request.content.userInfo objectForKey:@"id"] integerValue] == 1) {
//            if (0 != response.notification.request.content.body) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:response.notification.request.content.body delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }
        
//        if (0 != notification.request.content.title.length) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:notification.request.content.title delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
    }
    completionHandler();
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"BimSite"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


- (void)showRoot {
    //[UINavigationBar appearance].barTintColor = [UIColor navBarColor];
    //[UINavigationBar appearance].tintColor = [UIColor navTintColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    AppModel *appModel = [AppModel readModel];
    if (appModel == nil) {
        [self showLogin];
    }else {
        [self showTabController];
    }
}


#pragma mark - showLogin
- (void)showLogin
{
    if (!self.window) {
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
}

- (void)showTabController
{
    UIStoryboard *storyBoard = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
    }else{
        storyBoard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    
    UIViewController *vc = [storyBoard instantiateInitialViewController];
    
    if (!self.window) {
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    }else{
        UIViewController *rootVc = self.window.rootViewController;
        [rootVc.navigationController popToRootViewControllerAnimated:YES];
    }
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)logout {
    if (!self.window) {
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    }else{
        UIViewController *rootVc = self.window.rootViewController;
        [rootVc.navigationController popToRootViewControllerAnimated:YES];
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message containsString:@"条待办任务"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *vc = self.window.rootViewController;
            if ([vc isKindOfClass:[BSIPhoneViewController class]]) {
                BSIPhoneViewController *tb = (BSIPhoneViewController *)vc;
                HomeViewController *home = (HomeViewController *)tb.viewControllers.firstObject;
                [home goWork];
            }
        });
    }
}

@end
