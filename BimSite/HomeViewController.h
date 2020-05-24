//
//  HomeViewController.h
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) NSString* mQrcodeResult;
-(void)scanQrcodeForResult:(NSString*)result;
-(void)setWebQrcodeContent;

- (void)goWork;
@end
