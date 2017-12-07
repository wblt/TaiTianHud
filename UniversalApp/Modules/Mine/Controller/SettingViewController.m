//
//  SettingViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/29.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "SettingViewController.h"
#import <UMSocialCore/UMSocialCore.h>
#import "LTAlertView.h"
#import "EditPasswordViewController.h"
#import "EditPhoneViewController.h"
@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *arr;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.rowHeight = 55;
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    arr = @[@[@"修改手机号",@"修改密码"],@[[model.isvst boolValue]?@"绑定手机号":@"绑定微信",@"清除缓存"]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //默认导航栏样式：黑字
    self.StatusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:18]}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArr = arr[section];
    return sectionArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ideitifier = @"tgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideitifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ideitifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if ([arr[indexPath.section][indexPath.row] isEqualToString:@"绑定微信"]) {
        UISwitch *switchView = [[UISwitch alloc] init];
        [switchView setOn:[model.isbindwx boolValue]];
        [switchView addTarget:self action:@selector(bindWXAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }else {
        cell.accessoryView = nil;
    }
    cell.textLabel.text = arr[indexPath.section][indexPath.row];
    //获取缓存图片的大小(字节)
    NSUInteger bytesCache = [[SDImageCache sharedImageCache] getSize];
    
    //换算成 MB (注意iOS中的字节之间的换算是1000不是1024)
    float MBCache = bytesCache/1000/1000;
    if (indexPath.section == 1 && indexPath.row == 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", MBCache];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }else {
        return 80;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80)];
        view.backgroundColor = [UIColor clearColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 25, KScreenWidth, 55)];
        btn.backgroundColor = [UIColor orangeColor];
        [btn setTitle:@"退出登录" forState:0];
        [btn addTapBlock:^(UIButton *btn) {
            LTAlertView *alert;
            if (alert == nil) {
                alert = [[[NSBundle mainBundle] loadNibNamed:@"LTAlertView" owner:self options:nil] lastObject];
                alert.title = @"您确定要退出上位吗？";
                alert.frame = self.view.bounds;
                [self.view addSubview:alert];
            }
            alert.centainBlock = ^(UIView *view) {
                [view removeFromSuperview];
                [[UMSocialManager defaultManager] cancelAuthWithPlatform:UMSocialPlatformType_WechatSession completion:^(id result, NSError *error) {
                    if (!error) {
                        [[UserConfig shareInstace] logout];
                        
                        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        delegate.mainTabBar = [[TabBarViewController alloc] init];
                        delegate.window.rootViewController = delegate.mainTabBar;
                    }
                }];
            };
            
        }];
        [view addSubview:btn];
        return view;
    }
    return nil;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        LTAlertView *alert;
        if (alert == nil) {
            alert = [[[NSBundle mainBundle] loadNibNamed:@"LTAlertView" owner:self options:nil] lastObject];
            alert.title = [NSString stringWithFormat:@"您确定要清除%@缓存吗？", cell.detailTextLabel.text];
            alert.frame = self.view.bounds;
            [self.view addSubview:alert];
        }
        alert.centainBlock = ^(UIView *view) {
            [view removeFromSuperview];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            [[SDImageCache sharedImageCache] clearMemory];//可不写
            [tableView reloadData];
        };
    }else if (indexPath.section == 0 && indexPath.row == 1) {
        EditPasswordViewController *editVC = [[EditPasswordViewController alloc] init];
        [self.navigationController pushViewController:editVC animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 0) {
        UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        EditPhoneViewController *editPhoneVC = [storyboad instantiateViewControllerWithIdentifier:@"EditPhoneViewController"];
        editPhoneVC.title = @"修改手机号";
        [self.navigationController pushViewController:editPhoneVC animated:YES];
    }else {
        if ([arr[indexPath.section][indexPath.row] isEqualToString:@"绑定手机号"]) {
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            EditPhoneViewController *editPhoneVC = [storyboad instantiateViewControllerWithIdentifier:@"EditPhoneViewController"];
            editPhoneVC.title = @"绑定手机号";
            [self.navigationController pushViewController:editPhoneVC animated:YES];
        }
    }
}

-(void)bindWXAction:(UISwitch *)sender
{
    BOOL isButtonOn = [sender isOn];
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if ([model.wx_openid length] == 0) {
        [MBProgressHUD showActivityMessageInView:@"授权中..."];
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
            [MBProgressHUD hideHUD];
            if (error) {
                
            } else {
                
                UMSocialUserInfoResponse *resp = result;
                model.wx_openid = resp.openid;
                [[UserConfig shareInstace] setAllInformation:model];
                [NetRequestClass afn_requestURL:@"appBindWx" httpMethod:@"POST" params:@{@"isbindwx":isButtonOn?@(-1):@(1),@"ub_id":model.ub_id?model.ub_id:@"",@"ua_id":model.ua_id?model.ua_id:@"",@"wx_openid":resp.openid}.mutableCopy successBlock:^(id returnValue) {
                    if ([returnValue[@"status"] integerValue] == 1) {
                        [SVProgressHUD showSuccessWithStatus:returnValue[@"info"]];
                    }else {
                        [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
                        [sender setOn:!isButtonOn];
                    }
                } failureBlock:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:@"请求失败"];
                    [sender setOn:!isButtonOn];
                }];
            }
        }];
    }else {
        [NetRequestClass afn_requestURL:@"appBindWx" httpMethod:@"POST" params:@{@"isbindwx":isButtonOn?@(-1):@(1),@"ub_id":model.ub_id?model.ub_id:@"",@"ua_id":model.ua_id?model.ua_id:@"",@"wx_openid":model.wx_openid?model.wx_openid:@""}.mutableCopy successBlock:^(id returnValue) {
            if ([returnValue[@"status"] integerValue] == 1) {
                [SVProgressHUD showSuccessWithStatus:returnValue[@"info"]];
                
            }else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
                [sender setOn:!isButtonOn];
            }
        } failureBlock:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"请求失败"];
            [sender setOn:!isButtonOn];
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
