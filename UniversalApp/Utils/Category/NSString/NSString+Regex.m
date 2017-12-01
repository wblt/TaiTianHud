//
//  NSString+Regex.m
//  QidaCRM
//
//  Created by 彭石文 on 14-7-8.
//  Copyright (c) 2014年 深圳企大信息技术有限公司. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)


/**
 *  检查手机号码是否输入正确
 *
 *  @return true或false
 */
-(BOOL)checkPhoneNumInput
{
    
    NSString * str = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9])|(17[0-9]))\\d{8}$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
    
}


- (BOOL)checkISEightNum
{
    NSString * str = @"^1[0-9]{7}$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return [regextestStr evaluateWithObject:self];
}

/**
 *  登录手机号码的验证
 *  马甲 8位的或者是11位的
 *
 *  @return true或false
 */
- (BOOL)checkLoginPhoneNum
{
    return ([self checkPhoneNumInput] || [self checkISEightNum]);
}

/**
 *  检查邮箱是否输入正确
 *
 *  @return true或false
 */
-(BOOL) checkEmailInput
{
    NSString * str = @"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
}


/**
 @brief 验证是否数字和英文字母组成
 */
- (BOOL)checkIsNumberAndCharacter{
    
    NSString * str = @"^[A-Za-z0-9]+$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
    
}

/**
 *  检查是不是中英文组成
 *
 *  @return true或false
 */
- (BOOL)checkChineseAndEnglish
{
    NSString * str = @"^[A-Za-z\u4e00-\u9fa5]+$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
}

/**
 *  验证是中英文数字组成
 *
 *  @return true或false
 */
- (BOOL)checkChineseAndEnglishaAndDigital
{
    NSString * str = @"^[A-Za-z0-9\u4e00-\u9fa5]+$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
}

/**
 *
 * 验证座机
 *
 *  @return  true或false
 */
- (BOOL)checkFixPhone
{
    NSString * str = @"^[0][1-9]{2,3}[0-9]{5,10}$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    
    NSString * str1 = @"^[1-9]{1}[0-9]{5,8}$";
    NSPredicate *regextestStr1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str1];
    
    return ([regextestStr evaluateWithObject:self] || [regextestStr1 evaluateWithObject:self]);
}

/**
 *  检查是否是中文
 *
 *  @return true或false
 */
- (BOOL)checkISChinese{
    NSString *str = @"^[\u4E00-\u9FA5]*$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
}


/**
 *  删除空格
 *
 *  @return 删除空格后的字符串
 */
-(NSString*)deleteSpace{
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString) {
        return trimmedString;
    }else{
        return nil;
    }
}


/**
 *  检查是不是数字
 *
 *  @return true或false
 */
- (BOOL)checkIsNumber
{
    NSString * str = @"^[0-9]*$";
    NSPredicate *regextestStr = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    return  [regextestStr evaluateWithObject:self];
}

/**
 *  根据表达式获取字符串
 *
 *  @param regex 正则表达式
 *
 *  @return 返回匹配的字符串
 */
- (NSArray *)findStringByRegex:(NSString *)regex {
    
    //2.创建正则表达式实现对象
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    
    //3. expression  查找符合正则表达式的字符串
    NSArray *items = [expression matchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)];
    
    NSMutableArray *itemArray = [NSMutableArray array];
    //4.循环遍历查找出来的结果
    for (NSTextCheckingResult *result in items) {
        
        //符合表达的字符串的范围
        NSRange range = [result range];
        
        NSString *matchString = [self substringWithRange:range];
        [itemArray addObject:matchString];
    }
    
    return itemArray;
}

@end
