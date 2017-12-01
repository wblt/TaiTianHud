//
//  ReRegisterViewController.h
//  UniversalApp
//
//  Created by 何建波 on 2017/11/27.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "RootViewController.h"
typedef void(^ReregisterBackBlock)(NSString *);
@interface ReRegisterViewController : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *passwordFiled;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordFiled;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (nonatomic,copy) ReregisterBackBlock reregisterBackBlock;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *smsCode;
@property BOOL isFroget;
@end
