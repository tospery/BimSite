//
//  CommonWebViewController.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/22.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonWebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic) NSString* mH5Url;
@property (nonatomic) NSString* mQrcodeResult;

-(void)scanQrcodeForResult:(NSString*)result;
-(void)setWebQrcodeContent;
@end
