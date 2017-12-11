//
//  TabBarViewController.m
//
//  Created by HCl on 15/4/12.
//  Copyright (c) 2015年 HCl. All rights reserved.
//

#import "TabBarViewController.h"
#import "RootNavigationController.h"
#import "LoginViewController.h"
#import "EditPhoneViewController.h"
#import "SocketRocketUtility.h"
#import "MessageViewController.h"
#import "UITabBar+badge.h"
@interface TabBarViewController () <UIAlertViewDelegate,UITabBarDelegate,UITabBarControllerDelegate, UIApplicationDelegate>

@end

@implementation TabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.delegate = self;
    // 创建子控制器
    [self _createViewControllers];
    
    [self initSocket];
}

//1.创建子控制器
- (void)_createViewControllers
{
    //1、定义各个模块的故事版的文件名
    NSArray *storyboardNames = @[@"Home",@"Activity",@"Message",@"Mine"];
    NSArray *itemTitles = @[@"首页",@"活动",@"消息",@"我的"];
    NSArray *images = @[@"首页",@"活动",@"消息",@"我的"];
    NSArray *selectImages = @[@"首页（高亮）",@"活动（高亮）",@"消息（高亮）",@"我的（高亮）"];

    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:4];
    for (int i=0; i<storyboardNames.count; i++) {
        
        //2.取得故事板的文件名
        NSString *name = storyboardNames[i];
        
        //3.创建故事板加载对象
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];

        
        //设置未选中时的图标
        UIImage *image = [UIImage imageNamed:images[i]];
        //设置选中时的图标
        UIImage *selectedImage = [UIImage imageNamed:selectImages[i]];
        
        UITabBarItem *MytabBarItem = [[UITabBarItem alloc] initWithTitle:itemTitles[i] image:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        MytabBarItem.tag = i;


        [MytabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor grayColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Helvetica" size:12],NSFontAttributeName,
                                                           nil] forState:UIControlStateNormal];
        [MytabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor blackColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Helvetica" size:12],NSFontAttributeName,
                                                           nil] forState:UIControlStateSelected];
        //4.加载故事板，获取故事板中箭头指向的控制器对象
        RootNavigationController *navigation = [storyboard instantiateInitialViewController];
        navigation.navigationBar.translucent = NO;
        navigation.tabBarItem = MytabBarItem;
        [viewControllers addObject:navigation];
        if (i == 2) {
            UserModel *model = [[UserConfig shareInstace] getAllInformation];
            if ([[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]] > 0) {
                [navigation.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]]]];
            }
            
        }
    }
    
    //设置tabbar背景
    CGRect rect=CGRectMake(0.0f, 0.0f, kScreenWidth, 44.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setBackgroundImage:theImage];
    
    self.viewControllers = viewControllers;
    self.selectedIndex = 0;
	
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    self.tabBarController.hidesBottomBarWhenPushed = NO;
    return self.selectedViewController;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController NS_AVAILABLE_IOS(3_0){
    
    if (viewController.tabBarItem.tag == 3){
        
        if (![[UserConfig shareInstace] getLoginStatus]) {
            
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            LoginViewController *loginVC = [storyboad instantiateInitialViewController];
            [self presentViewController:loginVC animated:YES completion:nil];
            return NO;
        }else {
            return YES;
        }
    }else if (viewController.tabBarItem.tag == 2) {
        UserModel *model = [[UserConfig shareInstace] getAllInformation];
        if (![[UserConfig shareInstace] getLoginStatus]) {
            
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            LoginViewController *loginVC = [storyboad instantiateInitialViewController];
            [self presentViewController:loginVC animated:YES completion:nil];
            return NO;
        }else {
//            if ([model.ub_id length]==0){
//                [SVProgressHUD showErrorWithStatus:@"qing xian"];
//                return NO;
//            }
            UserModel *model = [[UserConfig shareInstace] getAllInformation];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [viewController.tabBarItem setBadgeValue:nil];
            return YES;
        }
    }else {
        return YES;
    }
    
}

- (void)initSocket {
    // 判断登录
    if (![[UserConfig shareInstace] getLoginStatus]) {
        return;
    }
    // 判断是否是用户
    UserModel *userModel = [[UserConfig shareInstace] getAllInformation];
    if (userModel.ub_id == nil || userModel.ub_id.length == 0) {
        return;
    }
    // 启动socket
    [[SocketRocketUtility instance] SRWebSocketOpen];//打开soket
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidOpen) name:@"kWebSocketDidOpenNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidReceiveMsg:) name:@"kWebSocketdidReceiveMessageNote" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRWebSocketDidClose) name:@"kWebSocketDidCloseNote" object:nil];
}

- (void)SRWebSocketDidOpen {
    NSLog(@"开启成功");
    //在成功后需要做的操作。。。
    // 绑定用户id
    //[self bingding];
}

- (void)SRWebSocketDidClose {
    NSLog(@"关闭成功");
}

- (void)SRWebSocketDidReceiveMsg:(NSNotification *)note {
    //收到服务端发送过来的消息
    NSString * message = note.object;
    NSLog(@"%@",message);
    if (message != nil) {
        NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        NSLog(@"消息类型：%@", jsonObject[@"type"]);
        if ([jsonObject[@"type"] isEqualToString:@"onConnect"]) {
            [self bingding:jsonObject[@"client_id"]];
        } else if([jsonObject[@"type"] isEqualToString:@"message"]) {
            UserModel *model = [[UserConfig shareInstace] getAllInformation];
            //[self.tabBar showBadgeOnItemIndex:2];
            [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]]+1 forKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            RootNavigationController *cc = self.viewControllers[2];
            [cc.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_badge",model.ub_id]]]];
            
        }
    
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bingding:(NSString *)client_id {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [NetRequestClass afn_requestURL:@"appBindUid" httpMethod:@"POST" params:@{@"ub_id":model.ub_id?model.ub_id:@"",@"client_id":client_id,@"device_id":uuid}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            NSLog(@"绑定成功");
//            [SVProgressHUD showSuccessWithStatus:returnValue[@"info"]];
        }else {
            NSLog(@"%@", returnValue[@"info"]);
//            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
//        [SVProgressHUD showErrorWithStatus:@"请求失败"];
    }];
}
@end
