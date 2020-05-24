//
//  LoginViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/14.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "LoginViewController.h"
#import "APPDefine.h"
#import "UserService.h"
#import "SVProgressHUD.h"
#import "AppModel.h"
#import <AFNetworking/AFNetworking.h>

#define NotificationTypePlainId @"notificationPlainId"
#define NotificationTypeServiceExtensionId @"notificationServiceExtensionId"
#define NotificationTypeContentExtensionId @"notificationContentExtensionId"

#define ActionIdentifier @"ActionIdentifier"


@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UITextField *loginName;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;

@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *wsServer;
@property (strong, nonatomic) IBOutlet UITextField *h5Server;

- (IBAction)btnLoginAction:(id)sender;
- (IBAction)switchServer:(id)sender;

@end

@implementation LoginViewController

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
    
    //加载用户密码图标
    UIImageView *userNameLeftViewIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LoginUser"]];
    //图片的显示模式
    userNameLeftViewIV.contentMode= UIViewContentModeCenter;
    userNameLeftViewIV.frame= CGRectMake(0,0,40,40);
    //左视图默认是不显示的 设置为始终显示
    self.loginName.leftViewMode= UITextFieldViewModeAlways;
    self.loginName.leftView= userNameLeftViewIV;
    
    //密码框的左视图
    UIImageView*passWordLeftViewIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Password"]];
    //设置图片中间显示
    passWordLeftViewIV.contentMode= UIViewContentModeCenter;
    passWordLeftViewIV.frame= CGRectMake(0,0, 40, 40);
    //设置左视图一直显示
    self.password.leftViewMode= UITextFieldViewModeAlways;
    self.password.leftView= passWordLeftViewIV;
    
    [self.btnLogin.layer setMasksToBounds:YES];
    [self.btnLogin.layer setCornerRadius:10.0];
    
    self.wsServer.text  = WS_SERVER_ADDRESS;
    self.h5Server.text  = H5_SERVER_ADDRESS;
    
//    self.loginName.text = @"appLead";
//    self.password.text = @"123";
    
    AppModel *appModel = [AppModel readPrevModel];
    if (appModel) {
        self.loginName.text = appModel.phone;
        //self.password.text  = appModel.passwd;
        
        if(appModel.wsserver.length != 0) {
            self.wsServer.text  = appModel.wsserver;
            
        }
        if(appModel.h5server.length != 0) {
            self.h5Server.text  = appModel.h5server;
        }
    }
    self.wsServer.hidden=YES;
    self.h5Server.hidden=YES;
    
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_loginName resignFirstResponder];
    [_password resignFirstResponder];
    [_wsServer resignFirstResponder];
    [_h5Server resignFirstResponder];
}

- (IBAction)btnLoginAction:(id)sender {
    [SVProgressHUD show];
    
    NSString *server = self.h5Server.text;
    server = [NSString stringWithFormat:@"http://%@/BimSiteApp/getUrl", server];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:server parameters:nil progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BOOL pass = NO;
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSString *addr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if ([addr isKindOfClass:[NSString class]]) {
                addr = [addr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([addr isEqualToString:self.wsServer.text]) {
                    pass = YES;
                }
            }
        }
        
        if (pass) {
            NSString *uid = self.loginName.text;
            NSString *pwd = self.password.text;
            NSString *wsserver = self.wsServer.text;
            NSString *h5server = self.h5Server.text;
            
            if (uid.length == 0) {
                [SVProgressHUD showErrorWithStatus:@"请输入账户"];
                return;
            }
            if (pwd.length == 0) {
                [SVProgressHUD showErrorWithStatus:@"请输入密码"];
                return;
            }
            
            [UserService loginWithUserName:uid andWithPassword:pwd andWidthServerAddress:wsserver widthFinish:^(LoginResultModel *model, NSString* result) {
                if(model == nil){
                    AppModel *appModel = [AppModel readModel];
                    if(appModel != nil){
                        if([appModel.phone isEqualToString:uid] && [appModel.passwd isEqualToString:pwd] && [appModel.wsserver isEqualToString:wsserver]){
                            [SVProgressHUD dismiss];
                            [appDelegate showTabController];//成功的处理
                        }
                        else{
                            [SVProgressHUD showErrorWithStatus:@"登录失败:服务器错误！"];
                        }
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"登录失败:服务器错误！"];
                    }
                }else if([model.StatusCode isEqualToString:@"S000"]){
                    AppModel *appModel = [[AppModel alloc]init];
                    appModel.phone = uid;
                    appModel.passwd = pwd;
                    appModel.isRemembered = NO;
                    appModel.isAutoLogined = YES;
                    
                    result=[result stringByReplacingOccurrencesOfString:@"Token"withString:@"token"];
                    result=[result stringByReplacingOccurrencesOfString:@"UserNo"withString:@"userNo"];
                    result=[result stringByReplacingOccurrencesOfString:@"Telephone"withString:@"telephone"];
                    result=[result stringByReplacingOccurrencesOfString:@"Cell"withString:@"cell"];
                    result=[result stringByReplacingOccurrencesOfString:@"UserImage"withString:@"userImage"];
                    result=[result stringByReplacingOccurrencesOfString:@"AuthorGroup"withString:@"authorGroup"];
                    result=[result stringByReplacingOccurrencesOfString:@"UserName"withString:@"userName"];
                    result=[result stringByReplacingOccurrencesOfString:@"Department"withString:@"department"];
                    
                    //            result=[result stringByReplacingOccurrencesOfString:@"Token"withString:@"token"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"UserNo"withString:@"userNo"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"Telephone"withString:@"telephone"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"Cell"withString:@"cell"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"UserImage"withString:@"authorGroup"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"AuthorGroup"withString:@"cell"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"UserName"withString:@"userName"];
                    //            result=[result stringByReplacingOccurrencesOfString:@"Department"withString:@"department"];
                    
                    appModel.userinfo = model.responseString; // result;//[LoginViewController convertToJSONData:model.Result];
                    appModel.wsserver = self.wsServer.text;
                    appModel.h5server = self.h5Server.text;
                    appModel.token    = model.Result.Token;
                    appModel.userName = model.Result.UserName;
                    appModel.authorGroup = model.Result.AuthorGroup;
                    appModel.userImage = model.Result.UserImage;
                    [appModel saveModel];
                    [SVProgressHUD dismiss];
                    
                    //fangshy test
                    /*UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                     
                     UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                     content.title = [NSString localizedUserNotificationStringForKey:@"Here is a test noti!" arguments:nil];
                     content.body = [NSString localizedUserNotificationStringForKey:@"I'am noti content body~" arguments:nil];
                     content.sound = [UNNotificationSound defaultSound];
                     content.categoryIdentifier = NotificationTypePlainId;
                     
                     UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"requestId" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2.0 repeats:NO]];
                     
                     [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                     NSLog(@"%@",error);
                     }];
                     UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:120 repeats:NO];
                     */
                    //end
                    [appDelegate showTabController];//成功的处理
                }else{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"登录失败:%@", model.StatusDesc]];
                }
            }];
        }else {
            [SVProgressHUD showInfoWithStatus:@"WS地址无效！！！"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showInfoWithStatus:@"H5地址无效！！！"];
    }];
}

- (IBAction)switchServer:(id)sender {
    if(self.wsServer.hidden==YES){
        self.wsServer.hidden=NO;
        self.h5Server.hidden=NO;
    }else{
        self.wsServer.hidden=YES;
         self.h5Server.hidden=YES;
    }
}


@end
