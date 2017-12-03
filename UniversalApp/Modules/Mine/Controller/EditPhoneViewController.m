//
//  EditPhoneViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/30.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "EditPhoneViewController.h"

@interface EditPhoneViewController ()
{
    NSString *code;
}
@property (assign, nonatomic) BOOL presenting;
@end

@implementation EditPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    code = @"";
    [_phoneText addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
}

// textField 长度限制
- (void)textFieldDidChanged:(UITextField *)textField
{
    if (textField == _phoneText) {
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

- (IBAction)smsCodeAction:(id)sender {
    if (![self.phoneText.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    
    [self countTimer];
    [NetRequestClass afn_requestURL:@"appMsg" httpMethod:@"GET" params:@{@"value":self.phoneText.text}.mutableCopy successBlock:^(id returnValue) {
        code = [NSString stringWithFormat:@"%@",returnValue[@"data"]];
        [SVProgressHUD showSuccessWithStatus:@"验证码已发送,请稍后"];
    } failureBlock:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"发送失败，请检测网络"];
    }];
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

- (IBAction)editPhoneAction:(id)sender {
    if (![self.phoneText.text checkPhoneNumInput]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码"];
        return;
    }
    if ([self.passwordText.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    if ([self.smsCodeFiled.text length] == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    if (![code isEqualToString:self.smsCodeFiled.text]) {
        [SVProgressHUD showErrorWithStatus:@"验证码错误"];
        return;
    }
    BOOL isbangd = [self.title isEqualToString:@"绑定手机号"]?YES:NO;
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if (isbangd) {
        [SVProgressHUD showWithStatus:@"绑定中..."];
        
        [NetRequestClass afn_requestURL:@"appVstReUserSbt" httpMethod:@"POST" params:@{@"mobile":self.phoneText.text, @"password":self.passwordText.text,@"ub_id":model.ub_id,@"openid":model.wx_openid,@"headpic":model.headpic,@"sex":model.sex,@"nickname":model.nickname}.mutableCopy  successBlock:^(id returnValue) {
            [SVProgressHUD dismiss];
            if ([returnValue[@"status"] integerValue] == 1) {
                [SVProgressHUD showErrorWithStatus:@"绑定成功"];
                model.ub_id = returnValue[@"data"][@"ub_id"];
                model.nickname = returnValue[@"data"][@"nickname"];
                [[UserConfig shareInstace] setAllInformation:model];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
        } failureBlock:^(NSError *error){
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"绑定失败"];
        }];
    }else {
        [SVProgressHUD showWithStatus:@"修改中..."];
        
        [NetRequestClass afn_requestURL:@"appTelSbt" httpMethod:@"POST" params:@{@"mobile":self.phoneText.text, @"password":self.passwordText.text,@"ub_id":model.ub_id}.mutableCopy  successBlock:^(id returnValue) {
            [SVProgressHUD dismiss];
            if ([returnValue[@"status"] integerValue] == 1) {
                [SVProgressHUD showErrorWithStatus:@"修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
        } failureBlock:^(NSError *error){
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }];
    }
    
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

@end
