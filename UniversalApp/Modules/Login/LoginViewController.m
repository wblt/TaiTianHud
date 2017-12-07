//
//  LoginViewController.m
//  HJKHiWatch
//
//  Created by AirTops on 15/11/27.
//  Copyright © 2015年 cn.hi-watch. All rights reserved.
//

#import "LoginViewController.h"
#import "TabBarViewController.h"
#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "ForgetPwdController.h"
#import "AppDelegate.h"
#import "RootNavigationController.h"
#import "UserModel.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_phoneNumFiled addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    //设置数据
    self.phoneNumFiled.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumFiledSave"];
    self.passwordFiled.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"passwordFiledSave"];;
}


// textField 长度限制
- (void)textFieldDidChanged:(UITextField *)textField
{
    if (textField == _phoneNumFiled) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

}

#pragma mark - 登陆
- (IBAction)loginAction:(id)sender {
    if (![self.phoneNumFiled.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    if ([self.passwordFiled.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
        return;
    }
    [SVProgressHUD showWithStatus:@"登录中..."];
    [NetRequestClass afn_requestURL:@"appLogin" httpMethod:@"POST" params:@{@"username":self.phoneNumFiled.text,@"password":self.passwordFiled.text}.mutableCopy  successBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        //创建用户模型对象
        
        if ([returnValue[@"status"] integerValue] == 1) {
        
            UserModel *userModel = [UserModel mj_objectWithKeyValues:returnValue[@"data"]];
            userModel.userPhoneNum = self.phoneNumFiled.text;
            userModel.userPassword = self.passwordFiled.text;
            [[UserConfig shareInstace] setAllInformation:userModel];
            [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumFiled.text forKey:@"phoneNumFiledSave"];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwordFiled.text forKey:@"passwordFiledSave"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // 保存登录状态
            [[UserConfig shareInstace] setLoginStatus:YES];
            
            //登陆成功，跳转至首页
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //NSInteger index = delegate.mainTabBar.selectedIndex;
            delegate.mainTabBar = [TabBarViewController new];
            delegate.mainTabBar.selectedIndex = 3;
            delegate.window.rootViewController = delegate.mainTabBar;
            
            //显示动画
            delegate.window.rootViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
            [UIView animateWithDuration:0.4 animations:^{
                delegate.window.rootViewController.view.transform = CGAffineTransformIdentity;
            }completion:nil];
            
           
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"登陆失败,请检测账号和密码"];
    }];
}

- (IBAction)wxLogin:(id)sender {
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
//    if ([model.wx_openid length]>0) {
//        NSDictionary *params = @{@"wx_openid":model.wx_openid, @"nickname":model.nickname, @"headpic":model.headpic, @"sex":model.sex};
//        [[UserManager sharedUserManager] loginToServer:params completion:^(BOOL success, NSString *des) {
//            if (success) {
//                DLog(@"登录成功");
//            }else{
//                DLog(@"登录失败：%@", des);
//            }
//        }];
//    }else {
        [userManager login:kUserLoginTypeWeChat completion:^(BOOL success, NSString *des) {
            if (success) {
                DLog(@"登录成功");
            }else{
                DLog(@"登录失败：%@", des);
            }
        }];
//    }
}
- (IBAction)toRegisterVC:(id)sender {
    //获取Main.storyboard
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    //获取Main.storyboard中的第2个视图
    RegisterViewController *registerController = [mainStory instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    registerController.registerBackBlock = ^(NSString *userName,NSString *userPassword) {
        self.phoneNumFiled.text = userName;
        self.passwordFiled.text = userPassword;
    };
    [self presentViewController:registerController animated:YES completion:nil];
}
- (IBAction)toForgetVC:(id)sender {
    //获取Main.storyboard
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    //获取Main.storyboard中的第2个视图
    RegisterViewController *registerController = [mainStory instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    registerController.isFroget = YES;
    registerController.registerBackBlock = ^(NSString *userName,NSString *userPassword) {
        self.phoneNumFiled.text = userName;
        self.passwordFiled.text = userPassword;
    };
    [self presentViewController:registerController animated:YES completion:nil];
}

- (IBAction)backDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
