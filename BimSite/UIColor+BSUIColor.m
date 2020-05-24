//
//  UIColor+BSUIColor.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "UIColor+BSUIColor.h"

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@implementation UIColor (BSUIColor)

+ (UIColor *)tabBarItemColor
{
    return UIColorFromRGBA(0x666666, 1.0);//[UIColor colorWithRed:63.0/255.0 green:96.0/255.0 blue:169.0/255.0 alpha:1.0];
}

+ (UIColor *)tabBarItemFocusColor
{
    return UIColorFromRGBA(0x3ad9ff, 1.0);//[UIColor colorWithRed:75.0/255.f green:126.0/255. blue:254.0/255. alpha:1.0];
}



+ (UIColor *)navBarColor
{
    return UIColorFromRGBA(0x4B7EFE, 1.0);
}

+ (UIColor *)navTintColor
{
    return UIColorFromRGBA(0x4B7EFE, 1.0);
}

+ (UIColor *)backGrayColor
{
    return [UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.0];
}

+ (UIColor *)grayborderColor
{
    return [UIColor colorWithRed:205/255.f green:203/255.f blue:205/255.f alpha:1.0];
}
@end
