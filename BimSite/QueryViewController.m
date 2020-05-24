//
//  QueryViewController.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/13.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "QueryViewController.h"
#import "UIColor+BSUIColor.h"
#include "CommonWebViewController.h"
#include "APPDefine.h"
#import "AppModel.h"

@interface QueryViewController ()

@end

@implementation QueryViewController
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AppModel *appModel = [AppModel readModel];
//    switch (indexPath.section) {
//        case 0:
//            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/plan/index", appModel.h5server];
//            
//            break;
//        case 1:
//            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/log/index",appModel.h5server];
//            break;
//        case 2:
//            switch (indexPath.row) {
//                case 0:
//                    mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/safe/index",appModel.h5server];
//                    break;
//                case 1:
//                    mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/quality/index",appModel.h5server];
//                    break;
//                case 2:
//                    mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/form/index",appModel.h5server];
//                    break;
//                case 3:
//                    mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/folder/getFolderTree",appModel.h5server];
//                    break;
//            }
//            break;
//        default:
//            
//            break;
//    }
//
//    [self performSegueWithIdentifier:@"PushH5Web" sender:nil];
//    
//    return;
    
    
    AppModel *appModel = [AppModel readModel];
    //********liuxu********
    switch (indexPath.row) {
        case 0:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/plan/index", appModel.h5server];
            break;
        case 1:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/log/index",appModel.h5server];
            break;
        case 2:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/safe/index",appModel.h5server];
            break;
        case 3:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/quality/index",appModel.h5server];
            break;
        case 4:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/form/index",appModel.h5server];
            break;
        case 5:
            mH5Url = [NSString stringWithFormat:@"http://%@/BimSiteApp/folder/getFolderTree",appModel.h5server];
            break;
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"PushH5Web" sender:nil];
    
    return;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"PushH5Web"]){
        ((CommonWebViewController*)segue.destinationViewController).mH5Url = mH5Url;
    }
}
/*
-(void)viewDidLayoutSubviews
{
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
