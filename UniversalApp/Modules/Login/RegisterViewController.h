//
//  RegisterViewController.h
//  HJKHiWatch
//
//  Created by AirTops on 15/11/27.
//  Copyright © 2015年 cn.hi-watch. All rights reserved.
//

#import "RootViewController.h"

typedef void(^RegisterBackBlock)(NSString *,NSString *);

@interface RegisterViewController : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *userNameFiled;
@property (weak, nonatomic) IBOutlet UITextField *smsCodeFiled;
@property (weak, nonatomic) IBOutlet UIButton *smsCodeBtn;

@property (nonatomic,copy) RegisterBackBlock registerBackBlock;
@property BOOL isFroget;
@end
