//
//  UserConfig.h
//  TaTaTa
//
//  Created by mac on 15/9/21.
//  Copyright (c) 2015年 wb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"


@interface UserConfig : NSObject

@property (nonatomic) int index;
/**
 *  创建单例对象
 *
 *  @return 返回创建的单例对象
 */
+ (UserConfig *)shareInstace;

/**
 *  保存用户所有的信息
 *
 *  @param userModel 用户数据模型
 */
- (void)setAllInformation:(UserModel *)userModel;

/**
 *  获取用户信息
 *
 *
 *  @return 返回用户数据
 */
- (UserModel *)getAllInformation;

/**
 *  退出登陆
 */
- (void)logout;

/**
 *  验证手机号码
 *
 *  @param mobileNum 验证的号码
 *
 *  @return 返回判断
 */
- (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 *  警告提示框
 *
 *  @param msg 需要提示的内容
 */
- (void)alterViewShow:(NSString *)msg;

/**
 @brief 根据文件路径来创建文件夹
 @param path 要创建文件夹的路径
 @return 返回path
 */
- (NSString *)createFileDirectory:(NSString *)path;

// 获取登录状态
- (BOOL) getLoginStatus;

// 设置登录状态
- (void) setLoginStatus:(BOOL)status;

@end
