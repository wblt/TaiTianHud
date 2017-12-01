//
//  ForgetPwdController.h
//  HJKHiWatch
//
//  Created by AirTops on 15/11/27.
//  Copyright © 2015年 cn.hi-watch. All rights reserved.
//

#import "RootViewController.h"

typedef void(^ForgetBackBlock)(NSString *,NSString *);

@interface ForgetPwdController : RootViewController

@property (weak, nonatomic) IBOutlet UIButton *smsCodeBtn;

@property (weak, nonatomic) IBOutlet UITextField *phoneNum;

@property (weak, nonatomic) IBOutlet UITextField *smsCodeFiled;

@property (weak, nonatomic) IBOutlet UITextField *passwordFiled;

@property (weak, nonatomic) IBOutlet UITextField *certainPassword;

@property (nonatomic,copy) ForgetBackBlock forgetBackBlock;


@end
