//
//  ForgetPwdController.m
//  HJKHiWatch
//
//  Created by AirTops on 15/11/27.
//  Copyright © 2015年 cn.hi-watch. All rights reserved.
//

#import "ForgetPwdController.h"

@interface ForgetPwdController ()
{
    NSString *code;
}

@property (assign, nonatomic) BOOL presenting;

@end

@implementation ForgetPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    code = @"";
    
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
     [_phoneNum addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

// textField 长度限制
- (void)textFieldDidChanged:(UITextField *)textField
{
    if (textField == _phoneNum) {
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
    if (![self.phoneNum.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    [self countTimer];
    [NetRequestClass afn_requestURL:@"appMsg" httpMethod:@"GET" params:@{@"value":self.phoneNum.text}.mutableCopy successBlock:^(id returnValue) {
        code = returnValue[@"data"];
        [SVProgressHUD showSuccessWithStatus:@"验证码已发送,请稍后"];
    } failureBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"发送失败，请检测网络"];
    }];
}


#pragma mark - 提交
- (IBAction)forgotPasswordAction:(id)sender {
    if (![self.phoneNum.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    if ([self.smsCodeFiled.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"验证码不为空"];
        return;
    }
    if ([self.passwordFiled.text length] < 6) {
        [SVProgressHUD showErrorWithStatus:@"密码不少于6位"];
        return;
    }
    
//    if (![code isEqualToString:self.smsCodeFiled.text]) {
//        [SVProgressHUD showErrorWithStatus:@"验证码错误"];
//        return;
//    }
    

    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if ([self.title isEqualToString:@"修改手机号码"]) {
        [SVProgressHUD showWithStatus:@"修改中..."];
        [NetRequestClass afn_requestURL:@"appTelSbt" httpMethod:@"POST" params:@{@"mobile":self.phoneNum.text,@"password":self.passwordFiled.text,@"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
            [SVProgressHUD dismiss];
            if ([returnValue[@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:0.5];
                
            }
            else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
            
        } failureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"修改失败,请检测网络"];
        }];
    }else {
        [SVProgressHUD showWithStatus:@"绑定中..."];
        [NetRequestClass afn_requestURL:@"appVstReUserSbt" httpMethod:@"POST" params:@{@"mobile":self.phoneNum.text,@"password":self.passwordFiled.text,@"openid":model.wx_openid?model.wx_openid:@"",@"headpic":model.headpic?model.headpic:@"",@"sex":model.sex?model.sex:@1,@"nickname":model.nickname?model.nickname:@""}.mutableCopy successBlock:^(id returnValue) {
            [SVProgressHUD dismiss];
            if ([returnValue[@"status"] integerValue] == 1) {
                model.ub_id = returnValue[@"data"][@"ub_id"];
                [[UserConfig shareInstace] setAllInformation:model];
                [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
                [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@(YES) afterDelay:0.5];
                
            }
            else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
            
        } failureBlock:^(NSError *error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"请求失败"];
        }];
    }
    
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

@end
