//
//  UserConfig.m
//  TaTaTa
//
//  Created by mac on 15/9/21.
//  Copyright (c) 2015年 wb. All rights reserved.
//

#import "UserConfig.h"

static  UserConfig *instance = nil;

@implementation UserConfig

/**
 *  创建单例对象
 *
 *  @return 返回创建的单例对象
 */
+ (UserConfig *)shareInstace {
    
    static dispatch_once_t onecToken = 0;
    
    dispatch_once(&onecToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (instance == nil) {
        instance = [super allocWithZone:zone];
    }
    
    return instance;
    
}

#pragma mark - 设置用户信息

/**
 *  保存用户所有的信息
 *
 *  @param userModel 用户数据模型
 */
- (void)setAllInformation:(UserModel *)userModel {
    //将账号归档
    NSString *localFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LocalFileDirectory"];
    NSString *localDir = [self createFileDirectory:localFilePath];
    NSString *userModelPath = [localDir stringByAppendingPathComponent:@"userModel.archive"];
    [NSKeyedArchiver archiveRootObject:userModel toFile:userModelPath];
}

/**
 *  获取用户的所有信息
 *
 *  @return 返回用户数据
 */
- (UserModel *)getAllInformation{
    NSString *localFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LocalFileDirectory"];
    NSString *localDir = [self createFileDirectory:localFilePath];
    NSString *userModelPath = [localDir stringByAppendingPathComponent:@"userModel.archive"];
    UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithFile:userModelPath];
    return userModel;
}

- (int)index
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"INDEX_LT"];
}

- (void)setIndex:(int)index
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"INDEX_LT"];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"INDEX_LT"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  退出登陆
 */
- (void)logout {
//    UserModel *user = [[UserConfig shareInstace] getAllInformation];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setAllInformation:nil];
}

#pragma mark - 验证相关方法
/**
 *  验证手机号码
 *
 *  @param mobileNum 验证的号码
 *
 *  @return 返回判断
 */
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9]|7[678])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[2378])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181
     22         */
    NSString * CT = @"^1((33|53|8[091])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
 *  警告提示框
 *
 *  @param msg 需要提示的内容
 */
- (void)alterViewShow:(NSString *)msg
{
    if ([msg isEqualToString:@"无数据"]) {
        
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg  delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dimissAlert:) withObject:alertView afterDelay:1.0];
    }
}

//警告框提示之后调用改方法，自动隐藏提示宽
- (void)dimissAlert:(UIAlertView *)alert {
    if(alert)     {
        [alert dismissWithClickedButtonIndex:[alert cancelButtonIndex] animated:YES];
    }
}

/**
 @brief 根据文件路径来创建文件夹
 @param path 要创建文件夹的路径
 @return 是否创建成功
 */
- (NSString *)createFileDirectory:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

// 获取登录状态
- (BOOL) getLoginStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
}

// 设置登录状态
- (void) setLoginStatus:(BOOL)status {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
