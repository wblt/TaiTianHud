//
//  UIWindow+Extension.m
//  TheMall
//
//  Created by quange on 15/6/5.
//  Copyright (c) 2015年 KingHan. All rights reserved.
//

#import "UIWindow+Extension.h"
//#import "AppDelegate.h"
//#import "LoginViewController.h"
//#import "HomeViewController.h"
//#import "UserConfig.h"
//#import "UserModel.h"
//#import "BaseNavigationController.h"
//#import "Util+System.h"
//#import "GuideViewController.h"
//#import "JPUSHService.h"
@implementation UIWindow (Extension)
/**
 *  切换到根视图控制器
 */
- (void)switchRootViewController
{
    /**
//     *  判断版本
//     */
//    NSString *key = kAppVersion;
//    // 上一次的使用版本（存储在沙盒中的版本号）
//    NSString *lastVersion = [kUserDefaults objectForKey:key];
//    // 当前软件的版本号（从Info.plist中获得）
//    NSString *currentVersion = [Util applicationVersion];
//    if ([currentVersion isEqualToString:lastVersion]) { // 版本号相同：这次打开和上次打开的是同一个版本
//        [self enterRootViewController];
//    } else { // 这次打开的版本和上一次不一样，显示新特性
////        GuideViewController *guideVC = [[GuideViewController alloc] init];
////        self.rootViewController = [[GuideViewController alloc] init];
////        guideVC.finishBlock = ^ {
//        [self enterRootViewController];
////        };
//        // 将当前的版本号存进沙盒
//        [kUserDefaults setObject:currentVersion forKey:key];
//        [kUserDefaults synchronize];
//    }

}

/**
 *  进入到主控制器
 */
- (void)enterRootViewController {
    /**
     *  判断是否登陆
     */
//    if ([kUserDefaults boolForKey:kIsLogin] == YES) {
//        //1.已经登陆，进入到主控制器
//        UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
//        HomeViewController *homeVC = [storyboad instantiateInitialViewController];
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        delegate.window.rootViewController = homeVC;
//        
//        UserModel *userModel = [kUserConfig getAllInformation];
//        NSSet *set = [NSSet setWithObject:userModel.userPhoneNum];
//        /**<设置JPush别名*/
//        [JPUSHService setTags:set alias:userModel.userPhoneNum fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//            NSLog(@"%d----%@---",iResCode,iAlias);
//        }];
//
//        //显示动画
//    }
//    else {
//        [UserConfig shareInstace].index = 0;
//        //2.没有登陆，进入到登陆界面,获取故事版创建的登陆控制器
//        UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        LoginViewController *loginVC = [storyboad instantiateInitialViewController];
//        self.rootViewController = loginVC;
//        
//        //显示动画
//        self.rootViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
//        [UIView animateWithDuration:0.4 animations:^{
//            self.rootViewController.view.transform = CGAffineTransformIdentity;
//        }completion:nil];
//    }
    
}
@end
