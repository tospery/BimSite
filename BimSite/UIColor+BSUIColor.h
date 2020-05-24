//
//  UIColor+BSUIColor.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JXColorHex(rgbValue)                    \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (BSUIColor)
+ (UIColor *)tabBarItemColor;
+ (UIColor *)tabBarItemFocusColor;

+ (UIColor *)navBarColor;
+ (UIColor *)navTintColor;
+ (UIColor *)backGrayColor;
+ (UIColor *)grayborderColor;  
@end
