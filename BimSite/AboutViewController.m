//
//  AboutViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/24.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "AboutViewController.h"
#import "UIColor+BSUIColor.h"

@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage * image = [UIImage imageNamed:@"logo"];
    UIImageView * imageV = self.logoImage;
    imageV.layer.masksToBounds = YES;
    imageV.layer.cornerRadius =imageV.frame.size.width / 2 ;
    /**如果需要边框，请把下面2行注释打开*/
    //imageV.layer.borderColor = [UIColor purpleColor].CGColor;
    //imageV.layer.borderWidth = 10;
    imageV.image=  image;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;// Black;
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:252./255. green:252./255. blue:252./255. alpha:1.];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    self.navigationController.navigationBar.backIndicatorImage = [UIImage imageNamed:@"navigation_back"];
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"navigation_back"];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
    self.view.backgroundColor = [UIColor whiteColor];

}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
