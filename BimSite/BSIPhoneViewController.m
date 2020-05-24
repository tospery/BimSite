//
//  BSIPhoneViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "BSIPhoneViewController.h"
#import "UIColor+BSUIColor.h"

@interface BSIPhoneViewController ()

@end

@implementation BSIPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor tabBarItemFocusColor]} forState:UIControlStateSelected];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor tabBarItemColor]} forState:UIControlStateNormal];
        
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    //返回根界面
    if ([item.title isEqualToString:@"首页"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backRoot" object:nil userInfo:@{@"index":@0}];
    }
    else if ([item.title isEqualToString:@"BIM应用"]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backRoot" object:nil userInfo:@{@"index":@1}];
    }
}

@end



