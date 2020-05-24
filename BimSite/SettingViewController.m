//
//  SettingViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "SettingViewController.h"
#import "UIColor+BSUIColor.h"
#import "CommonWebViewController.h"
#include "APPDefine.h"
#import "AppModel.h"
#import "SVProgressHUD.h"
#import "HSDownloadManager.h"

@interface SettingViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation SettingViewController
@synthesize mH5Url;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor:[UIColor navTintColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    CGFloat navBarHeight = 25.0f;
    CGRect frame = CGRectMake(0.0f, 20.0f, 320.0f, navBarHeight);
    [bar setFrame:frame];


    
//    AppModel *appModel = [AppModel readModel];
//    if (appModel){
//        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:appModel.userImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
//        self.userImage.image = [UIImage imageWithData:imageData];
//        self.userImage.layer.masksToBounds = YES;
//        self.userImage.layer.cornerRadius  = self.userImage.frame.size.width / 2 ;
//    }
    
    AppModel *appModel = [AppModel readModel];
    //********liuxu********
    //添加 && appModel.userImage防止删除缓存后崩溃
    if (appModel && appModel.userImage){
        if ([appModel.userImage isKindOfClass:[NSString class]]) {
            if (0 != appModel.userImage.length) {
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:appModel.userImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
                self.userImage.image = [UIImage imageWithData:imageData];
                self.userImage.layer.masksToBounds = YES;
                self.userImage.layer.cornerRadius  = self.userImage.frame.size.width / 2 ;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppModel *appModel = [AppModel readModel];
    switch (indexPath.section) {
        case 0:
        case 1:
            switch (indexPath.row) {
                case 0:
                    mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/person/accountManager",appModel.h5server];
                    [self performSegueWithIdentifier:@"pushZhanghao" sender:nil];
                    break;
                case 1:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:@"正在清理缓存..."];
                        [self clearAsyncCache];
                        // 通知主线程刷新 神马的
                        //[self performSelectorOnMainThread: @selector(clearAsyncCache) withObject: nil waitUntilDone: NO];
                    });
                    
                    //
                }
                    break;
                case 2:
                    break;
                case 3:
                    break;
            }
            break;
        default:
            
            break;
    }
}

-(void)clearAsyncCache
{
//    [SettingViewController clearCache:[[HSDownloadManager sharedInstance] getCachePath]];
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies]){
//        [storage deleteCookie:cookie];
//    }
    
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];
//    NSURLCache * cache = [NSURLCache sharedURLCache];
//    [cache removeAllCachedResponses];
//    [cache setDiskCapacity:0];
//    [cache setMemoryCapacity:0];
    
//    AppModel *appModel = [AppModel readModel];
//    [appModel clearModelWhenLogout];
    //[NSThread sleepForTimeInterval:10];
    //[SVProgressHUD dismiss];
    
    NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bsh5loc"];
    NSString *jsonURL = [NSString stringWithFormat:@"%@/Android_3DAir/json/WebGlTest", pagePath];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:jsonURL];
    for (NSString *fileName in enumerator) {
        [[NSFileManager defaultManager] removeItemAtPath:[jsonURL stringByAppendingPathComponent:fileName] error:nil];
    }
    
    //********liuxu********
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath* indexpath = [NSIndexPath indexPathForRow:1 inSection:1];
        [weakSelf.tableView deselectRowAtIndexPath:indexpath animated:NO];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"pushZhanghao"]){
        ((CommonWebViewController*)segue.destinationViewController).mH5Url = mH5Url;
    }
}

#pragma mark - 下面两个获取文件大小的返回值都是数据类型,可以用NSString stringWithFormat转换成字符串
//单个文件的大小
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil]  fileSize];
    }
    return 0;
}


//遍历文件夹获得文件夹大小，返回多少M
- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager   defaultManager];
    if (![manager  fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        
    }
    return folderSize/(1024.0*1024.0);
}

#pragma mark - 清除缓存的方法
+(void)clearCache:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    
    // 这个是清除SDWebImage的缓存的,没有引用这个第三方类库不用写
    //[[SDImageCache sharedImageCache] cleanDisk];
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
