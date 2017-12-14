//
//  UserManager.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/22.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "UserManager.h"
#import <UMSocialCore/UMSocialCore.h>
@implementation UserManager

SINGLETON_FOR_CLASS(UserManager);

-(instancetype)init{
    self = [super init];
    if (self) {
        //被踢下线
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKick)
                                                     name:KNotificationOnKick
                                                   object:nil];
    }
    return self;
}

#pragma mark ————— 三方登录 —————
-(void)login:(UserLoginType )loginType completion:(loginBlock)completion{
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        [self login:loginType params:nil completion:completion];
    }else {
        if (completion) {
            completion(NO,nil);
        }
    }
    
}

#pragma mark ————— 带参数登录 —————
-(void)login:(UserLoginType )loginType params:(NSDictionary *)params completion:(loginBlock)completion{
    //友盟登录类型
    UMSocialPlatformType platFormType;
    
    if (loginType == kUserLoginTypeQQ) {
        platFormType = UMSocialPlatformType_QQ;
    }else if (loginType == kUserLoginTypeWeChat){
        platFormType = UMSocialPlatformType_WechatSession;
    }else{
        platFormType = UMSocialPlatformType_UnKnown;
    }
    //第三方登录
    if (loginType != kUserLoginTypePwd) {
        [MBProgressHUD showActivityMessageInView:@"授权中..."];
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
            if (error) {
                [MBProgressHUD hideHUD];
                if (completion) {
                    completion(NO,error.localizedDescription);
                }
            } else {
                
                UMSocialUserInfoResponse *resp = result;
                
                //登录参数
                NSDictionary *params = @{@"wx_openid":resp.openid, @"nickname":resp.name, @"headpic":resp.iconurl, @"sex":[resp.unionGender isEqualToString:@"男"]?@1:@2};
                //登录到服务器
                [self loginToServer:params completion:completion];
                
            }
        }];
    }else{
        //账号登录 暂未提供  
    }
}

#pragma mark ————— 手动登录到服务器 —————
-(void)loginToServer:(NSDictionary *)params completion:(loginBlock)completion{
    [MBProgressHUD showActivityMessageInView:@"登录中..."];
    [NetRequestClass afn_requestURL:@"appWxLogin" httpMethod:@"POST" params:params.mutableCopy successBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        if ([returnValue[@"status"] integerValue] == 1) {
            UserModel *userModel = [UserModel mj_objectWithKeyValues:returnValue[@"data"]];
            [[UserConfig shareInstace] setAllInformation:userModel];
            
            // 保存登录状态
            [[UserConfig shareInstace] setLoginStatus:YES];
            
            //登陆成功，跳转至首页
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //NSInteger index = delegate.mainTabBar.selectedIndex;
            delegate.mainTabBar = [TabBarViewController new];
            delegate.mainTabBar.selectedIndex = 3;
            delegate.window.rootViewController = delegate.mainTabBar;
            
            //显示动画
//            delegate.window.rootViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
//            [UIView animateWithDuration:0.4 animations:^{
//                delegate.window.rootViewController.view.transform = CGAffineTransformIdentity;
//            }completion:nil];
            
        }else {
            if (completion) {
                completion(NO,@"登录返回数据异常");
            }
            KPostNotification(KNotificationLoginStateChange, @NO);
        }
    } failureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        if (completion) {
            completion(NO,error.localizedDescription);
        }

    }];
}

#pragma mark ————— 自动登录到服务器 —————
-(void)autoLoginToServer:(loginBlock)completion{
//    [PPNetworkHelper POST:NSStringFormat(@"%@%@",URL_main,URL_user_auto_login) parameters:nil success:^(id responseObject) {
//        [self LoginSuccess:responseObject completion:completion];
//        
//    } failure:^(NSError *error) {
//        if (completion) {
//            completion(NO,error.localizedDescription);
//        }
//    }];
}

#pragma mark ————— 登录成功处理 —————
//-(void)LoginSuccess:(id )responseObject completion:(loginBlock)completion{
//    if (ValidDict(responseObject)) {
//        if ([responseObject[@"status"] integerValue] == 1) {
//            [MBProgressHUD hideHUD];
//            UserModel *userModel = [UserModel mj_objectWithKeyValues:responseObject[@"data"]];
//            [[UserConfig shareInstace] setAllInformation:userModel];
//            
//            // 保存登录状态
//            [[UserConfig shareInstace] setLoginStatus:YES];
//            if (completion) {
//                completion(YES,nil);
//            }
//            KPostNotification(KNotificationLoginStateChange, @YES);
//            
//        }else{
//            if (completion) {
//                completion(NO,@"登录返回数据异常");
//            }
//            KPostNotification(KNotificationLoginStateChange, @NO);
//            
//        }
//    }else{
//        if (completion) {
//            completion(NO,@"登录返回数据异常");
//        }
//        KPostNotification(KNotificationLoginStateChange, @NO);
//    }
//    
//}
#pragma mark ————— 储存用户信息 —————
-(void)saveUserInfo{
    if (self.curUserInfo) {
        YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
        NSDictionary *dic = [self.curUserInfo modelToJSONObject];
        [cache setObject:dic forKey:KUserModelCache];
    }
    
}
#pragma mark ————— 加载缓存的用户信息 —————
-(BOOL)loadUserInfo{
    YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
    NSDictionary * userDic = (NSDictionary *)[cache objectForKey:KUserModelCache];
    if (userDic) {
        self.curUserInfo = [UserModel modelWithJSON:userDic];
        return YES;
    }
    return NO;
}
#pragma mark ————— 被踢下线 —————
-(void)onKick{
    [self logout:nil];
}
#pragma mark ————— 退出登录 —————
- (void)logout:(void (^)(BOOL, NSString *))completion{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLogout object:nil];//被踢下线通知用户退出直播间
    
    [[IMManager sharedIMManager] IMLogout];
    
    self.curUserInfo = nil;
    self.isLogined = NO;

//    //移除缓存
    YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
    [cache removeAllObjectsWithBlock:^{
        if (completion) {
            completion(YES,nil);
        }
    }];
    
    KPostNotification(KNotificationLoginStateChange, @NO);
}

- (void)loginWithActivityDetailCompletion:(loginBlock)completion
{
    
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
            if (!error) {
                
                UMSocialUserInfoResponse *resp = result;
                
                //登录参数
                NSDictionary *params = @{@"wx_openid":resp.openid, @"nickname":resp.name, @"headpic":resp.iconurl, @"sex":[resp.unionGender isEqualToString:@"男"]?@1:@2};
                [NetRequestClass afn_requestURL:@"appWxLogin" httpMethod:@"POST" params:params.mutableCopy successBlock:^(id returnValue) {
                    [MBProgressHUD hideHUD];
                    if ([returnValue[@"status"] integerValue] == 1) {
                        UserModel *userModel = [UserModel mj_objectWithKeyValues:returnValue[@"data"]];
                        [[UserConfig shareInstace] setAllInformation:userModel];
                        
                        // 保存登录状态
                        [[UserConfig shareInstace] setLoginStatus:YES];

                        if (completion) {
                            completion(YES,nil);
                        }
                    }else {
                        if (completion) {
                            completion(NO,nil);
                        }
                    }
                } failureBlock:^(NSError *error) {
                    if (completion) {
                        completion(NO,nil);
                    }
                    
                }];
            }else {
                if (completion) {
                    completion(NO,nil);
                }
            }
        }];
    
}

@end
