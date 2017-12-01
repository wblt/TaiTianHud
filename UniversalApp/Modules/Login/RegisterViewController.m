//
//  RegisterViewController.m
//  HJKHiWatch
//
//  Created by AirTops on 15/11/27.
//  Copyright © 2015年 cn.hi-watch. All rights reserved.
//

#import "RegisterViewController.h"
#import "ReRegisterViewController.h"

@interface RegisterViewController ()
{
    NSString *code;
}
@property (assign, nonatomic) BOOL presenting;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"注册新用户";
    self.navigationController.navigationBarHidden = YES;
    code = @"";
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
    [_userNameFiled addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

// textField 长度限制
- (void)textFieldDidChanged:(UITextField *)textField
{
    if (textField == _userNameFiled) {
        if (textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.presenting = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.presenting = NO;
    
}

#pragma mark - 获取验证码
- (IBAction)getSmsCodeAction:(id)sender {
    if (![self.userNameFiled.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    [self countTimer];
    [NetRequestClass afn_requestURL:@"appMsg" httpMethod:@"GET" params:@{@"value":self.userNameFiled.text}.mutableCopy successBlock:^(id returnValue) {
        code = returnValue[@"data"];
        [SVProgressHUD showSuccessWithStatus:@"验证码已发送,请稍后"];
    } failureBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"发送失败，请检测网络"];
    }];
}

#pragma mark - 注册
- (IBAction)toReregisterAction:(id)sender {
    if (![self.userNameFiled.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    if ([self.smsCodeFiled.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的验证码"];
        return;
    }
    
    if (![code isEqualToString:self.smsCodeFiled.text]) {
        [SVProgressHUD showErrorWithStatus:@"验证码错误"];
        return;
    }
    
    //获取Main.storyboard
    UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    //获取Main.storyboard中的第2个视图
    ReRegisterViewController *reregisterController = [mainStory instantiateViewControllerWithIdentifier:@"ReRegisterViewController"];
    reregisterController.isFroget = _isFroget;
    reregisterController.userName = self.userNameFiled.text;
    reregisterController.smsCode = self.smsCodeFiled.text;
    reregisterController.reregisterBackBlock = ^(NSString *userPassword) {
        if (self.registerBackBlock) {
            self.registerBackBlock(self.userNameFiled.text, userPassword);
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    };
    [self presentViewController:reregisterController animated:YES completion:nil];
}
- (void)countTimer {
    //4.60s计时
    self.smsCodeBtn.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int counter = 60;
        while (--counter >= 0 && _presenting) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.smsCodeBtn setTitle: [NSString stringWithFormat:@"%d秒", counter + 1] forState: UIControlStateDisabled];
            });
            [NSThread sleepForTimeInterval:1];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.smsCodeBtn.enabled = YES;
        });
    });
}

- (IBAction)toBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
