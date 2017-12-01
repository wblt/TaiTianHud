//
//  NSString+Extend.h
//  ZPEnterprise
//
//  Created by quange on 15/6/5.
//  Copyright (c) 2015年 KingHan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)

/**
 *  根据字体判断CGSize
 *
 *  @param rectSize 传进来的CGSize
 *  @param fontSize 字体的大小
 *
 *  @return CGSize
 */
- (CGSize)getSizeFromStringWithRectSize:(CGSize)rectSize fontSize:(CGFloat)fontSize;

/**
 *  判断字符串是不是为空
 */
- (BOOL)isEmptyString;

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;

@end
