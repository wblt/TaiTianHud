//
//  AppDelegate.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/17.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "AppDelegate.h"
#import "MessageModel.h"
#import "RootWebViewController.h"
@interface AppDelegate () <UIAlertViewDelegate>
{
    MessageModel *model;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化window
    [self initWindow];
    
    //本地推送
    [self requestAuthor];
    
    //UMeng初始化
    [self initUMeng];
    
    //初始化app服务
    [self initService];
    
    //初始化IM
    [[IMManager sharedIMManager] initIM];
    [WXApi registerApp:kAppKey_Wechat];
    //初始化用户系统
    [self initUserManager];
    
    //网络监听
    [self monitorNetworkStatus];
    
    //广告页
    //[AppManager appStart];
    
    return YES;
}

//创建本地通知
- (void)requestAuthor
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 设置通知的类型可以为弹窗提示,声音提示,应用图标数字提示
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        // 授权通知
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//    model = [MessageModel mj_objectWithKeyValues:userInfo[@"list"]];
//    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"消息" message:model.title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"查看", nil];
//    
//    [alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([model.ishref integerValue] == 1) {
            UserModel *user = [[UserConfig shareInstace] getAllInformation];
            [NetRequestClass afn_requestURL:@"appOperationMsg" httpMethod:@"POST" params:@{@"ub_id":user.ub_id,@"msg_id":model.msg_id,@"type":@"isread"}.mutableCopy successBlock:^(id returnValue) {
                NSInteger bagdeCount = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
                if ([returnValue[@"status"] integerValue] == 1) {
                    
                    bagdeCount -= 1;
                    
                }
                [[NSUserDefaults standardUserDefaults] setInteger:bagdeCount forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                RootNavigationController *cc = self.mainTabBar.viewControllers[2];
                [cc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",bagdeCount]];
            } failureBlock:^(NSError *error) {
            }];
            if ([model.url length] > 0) {
                RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:nil]];
                loginNavi.title = @"消息详情";
                [self.getCurrentVC presentViewController:loginNavi animated:YES completion:nil];
            }else {
                if ([model.module isEqualToString:@"artonce"]) {
                    [NetRequestClass afn_requestURL:@"appGetArtonce" httpMethod:@"GET" params:@{@"id":model.module_id}.mutableCopy successBlock:^(id returnValue) {
                        if ([returnValue[@"status"] integerValue] == 1) {
                            RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:nil orHtml:[NSString stringWithFormat:@"<h1 style=\"font-size: 40px;text-align: center;margin-left: 10%%;width: 80%%;margin-top: 40px;\">%@</h1>%@",returnValue[@"data"][@"title"],returnValue[@"data"][@"content"]]]];
                            loginNavi.title = @"消息详情";
                            [self.getCurrentVC presentViewController:loginNavi animated:YES completion:nil];
                        }
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            }
            
        }else {
            self.mainTabBar.selectedIndex = 2;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                            
                                            settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     [UIApplication sharedApplication].applicationIconBadgeNumber = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
