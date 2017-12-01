//
//  ReRegisterViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/27.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "ReRegisterViewController.h"
#import "LoginViewController.h"
@interface ReRegisterViewController ()

@end

@implementation ReRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.registerBtn setTitle:_isFroget?@"修改密码":@"注册" forState:0];
    //去掉导航栏黑线
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
}

#pragma mark - 注册
- (IBAction)registerAction:(id)sender {
    
    if ([self.passwordFiled.text length] < 6) {
        [SVProgressHUD showErrorWithStatus:@"密码至少为6位"];
        return;
    }
    if ([self.rePasswordFiled.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入确认密码"];
        return;
    }
    if (![self.rePasswordFiled.text isEqualToString:self.passwordFiled.text]) {
        [SVProgressHUD showErrorWithStatus:@"确认密码不一致"];
        return;
    }
    
    if (!_agreeBtn.selected) {
        [SVProgressHUD showErrorWithStatus:@"请同意遵循协议"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"注册中..."];
    
    NSString *url = _isFroget?@"appForget":@"appReg";
    
    [NetRequestClass afn_requestURL:url httpMethod:@"POST" params:@{@"mobile":self.userName,@"password":self.passwordFiled.text}.mutableCopy  successBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        if ([returnValue[@"status"] integerValue] == 1) {
            //注册成功，跳转到登陆页码
            [SVProgressHUD showSuccessWithStatus:_isFroget?@"修改成功":@"注册成功"];
            [self dismissViewControllerAnimated:NO completion:nil];
            if (self.reregisterBackBlock) {
                self.reregisterBackBlock(self.passwordFiled.text);
            }
            
//            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            LoginViewController *loginVC = [storyboad instantiateInitialViewController];
//
//            self.view.window.rootViewController = loginVC;
        
        
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:_isFroget?@"修改失败":@"注册失败"];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)isAgreeAction:(UIButton *)sender {
    _agreeBtn.selected = !_agreeBtn.selected;
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
