//
//  NSString+Regex.h
//  QidaCRM
//
//  Created by quange on 15/6/5.
//  Copyright (c) 2015年 KingHan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regex)

/**
 *  检查手机号码是否输入正确
 *
 *  @return true或false
 */
-(BOOL)checkPhoneNumInput;

/**
 *  检查邮箱是否输入正确
 *
 *  @return true或false
 */
-(BOOL)checkEmailInput;

/**
 *  验证是否数字和英文字母组成
 *
 *  @return true或false
 */
-(BOOL)checkIsNumberAndCharacter;

/**
 *  检查是否是中文
 *
 *  @return true或false
 */
- (BOOL)checkISChinese;

/**
 *  检查是不是数字
 *
 *  @return true或false
 */
- (BOOL)checkIsNumber;

/**
 *  删除空格
 *
 *  @return 删除空格后的字符串
 */
-(NSString *)deleteSpace;

/**
 *  检查是不是中英文组成
 *
 *  @return true或false
 */
- (BOOL)checkChineseAndEnglish;

/**
 *  验证是中英文数字组成
 *
 *  @return true或false
 */
- (BOOL)checkChineseAndEnglishaAndDigital;

/**
 *  登录手机号码的验证
 *
 *  @return true或false
 */
- (BOOL)checkLoginPhoneNum;

/**
 *
 * 验证座机
 *
 *  @return  true或false
 */
- (BOOL)checkFixPhone;

/**
 *  根据表达式获取字符串
 *
 *  @param regex 正则表达式
 *
 *  @return 返回匹配的字符串
 */
- (NSArray *)findStringByRegex:(NSString *)regex;

@end
