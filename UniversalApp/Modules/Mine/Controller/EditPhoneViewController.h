//
//  EditPhoneViewController.h
//  UniversalApp
//
//  Created by 何建波 on 2017/11/30.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "RootViewController.h"

@interface EditPhoneViewController : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeFiled;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *smsCodeBtn;
@end
