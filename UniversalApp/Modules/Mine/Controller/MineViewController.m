//
//  MineViewController.m
//  TaitianHud
//
//  Created by wb on 2017/10/19.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "MineViewController.h"
#import "UserModel.h"
#import "UserConfig.h"
#import "InformationEditViewController.h"
#import "ForgetPwdController.h"
#import <UMSocialCore/UMSocialCore.h>
#import "SettingViewController.h"
#import "AboutViewController.h"
@interface MineViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray *arr;
    NSMutableArray *imgArr;
    UIImagePickerController *imagePicker;
    UIImage *originalImage;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的";
    self.tableViewMain.bounces = NO;
    self.tableViewMain.dataSource = self;
    self.tableViewMain.delegate = self;
    self.tableViewMain.rowHeight = 55;
    self.tableViewMain.backgroundColor = [UIColor groupTableViewBackgroundColor];
    arr = @[@[@"我的钱包",@"我的任务",@"完善个人信息"],@[@"设置",@"关于上位"]].mutableCopy;
    imgArr = @[@[@"钱包",@"任务",@"个人信息"],@[@"设置",@"关于上位"]].mutableCopy;
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.StatusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navImage"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:CNavBgFontColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :CNavBgFontColor, NSFontAttributeName : [UIFont systemFontOfSize:18]}];
    [self requestData];
}

- (void)requestData
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    NSMutableDictionary *dic = @{@"islogin":[model.isvst boolValue]?@(2):@(1),
                                 @"openid":model.wx_openid?model.wx_openid:@"",
                                 @"headimgurl":model.headpic?model.headpic:@"",
                                 @"sex":model.sex?model.sex:@"",
                                 @"nickname":model.nickname?model.nickname:@""}.mutableCopy;
    if ([model.ub_id length]>0) {
        [dic addEntriesFromDictionary:@{@"ub_id":model.ub_id?model.ub_id:@""}];
    }
    [NetRequestClass afn_requestURL:@"appIndex" httpMethod:@"POST" params:dic successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            
            UserModel *userModel = [UserModel mj_objectWithKeyValues:returnValue[@"data"]];
            userModel.userPhoneNum = model.userPhoneNum;
            userModel.userPassword = model.userPassword;
            [[UserConfig shareInstace] setAllInformation:userModel];
//            if (![model.isvst boolValue]) {
//                arr = @[].mutableCopy;
//                if ([userModel.isopen[@"wallet"] boolValue]) {
//                    [arr addObject:@"我的钱包"];
//                }
//                if ([userModel.isopen[@"task"] boolValue]) {
//                    [arr addObject:@"我的任务"];
//                }
//                if ([userModel.isopen[@"headpic"] boolValue]) {
//                    [arr addObject:@"头像上传"];
//                }
//                if ([userModel.isopen[@"info"] boolValue]) {
//                    [arr addObject:@"完善个人信息"];
//                }
//                if ([userModel.isopen[@"tel"] boolValue]) {
//                    [arr addObject:@"修改手机号码"];
//                }
//                if ([userModel.isopen[@"bindwx"] boolValue]) {
//                    [arr addObject:@"绑定微信账号"];
//                }
//
//                if ([userModel.isopen[@"activity"] boolValue]) {
//                    [arr addObject:@"我的活动"];
//                }
//            }
            [self.tableViewMain reloadData];
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
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
        // 1. xib  缓存池中没有通过 loadNibNamed...方法加载重写创建
        //       cell = [[[NSBundle mainBundle] loadNibNamed:@"TgCell" owner:nil options:nil] lastObject];
        // 2. storyboard      缓存池中没有通过 initWithStyle...方法加载重写创建
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ideitifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if ([arr[indexPath.section][indexPath.row] isEqualToString:@"绑定微信账号"]) {
        UISwitch *switchView = [[UISwitch alloc] init];
        [switchView setOn:[model.isbindwx boolValue]];
        [switchView addTarget:self action:@selector(bindWXAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }else {
        cell.accessoryView = nil;
    }
    cell.imageView.image = [UIImage imageNamed:imgArr[indexPath.section][indexPath.row]];
    cell.textLabel.text = arr[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 140;
    }else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UserModel *model = [[UserConfig shareInstace] getAllInformation];
        UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"PersonHeadView" owner:self options:nil] lastObject];
        UIImageView *img = (UIImageView *)[v viewWithTag:201];
        [img sd_setImageWithURL:[NSURL URLWithString:model.headpic] placeholderImage:[UIImage imageNamed:@"friend_default"]];
        UILabel *name = (UILabel *)[v viewWithTag:202];
        name.text = [NSString stringWithFormat:@"%@ • %@", model.nickname, [model.sex integerValue]==1?@"男":@"女"];
        UIButton *bangd = (UIButton *)[v viewWithTag:203];
        if (![model.isvst boolValue]) {
            bangd.hidden = YES;
        }else {
            bangd.hidden = NO;
        }
        [bangd addTapBlock:^(UIButton *btn) {
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            ForgetPwdController *forgetVC = [storyboad instantiateViewControllerWithIdentifier:@"ForgetPwdController"];
            forgetVC.title = @"绑定手机号码";
            [forgetVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:forgetVC animated:YES];
        }];
        return v;
    }else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    if ([model.isvst boolValue]&&![arr[indexPath.section][indexPath.row] isEqualToString:@"绑定微信账号"]) {
        UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        ForgetPwdController *forgetVC = [storyboad instantiateViewControllerWithIdentifier:@"ForgetPwdController"];
        forgetVC.title = @"绑定手机号码";
        [forgetVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:forgetVC animated:YES];
    }else {
        if ([arr[indexPath.section][indexPath.row] isEqualToString:@"设置"]) {
            SettingViewController *set = [[SettingViewController alloc] init];
            [set setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:set animated:YES];
        }else if ([arr[indexPath.section][indexPath.row] isEqualToString:@"完善个人信息"]) {
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            InformationEditViewController *inforVC = [storyboad instantiateViewControllerWithIdentifier:@"InformationEditViewController"];
            [inforVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:inforVC animated:YES];
        }else if ([arr[indexPath.section][indexPath.row] isEqualToString:@"修改手机号码"]) {
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            ForgetPwdController *forgetVC = [storyboad instantiateViewControllerWithIdentifier:@"ForgetPwdController"];
            forgetVC.title = @"修改手机号码";
            [forgetVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:forgetVC animated:YES];
        }else if ([arr[indexPath.section][indexPath.row] isEqualToString:@"我的活动"]) {
            //暂无活动，
            //跳转页面展示活动列表
            [NetRequestClass afn_requestURL:@"appPartyList" httpMethod:@"GET" params:nil successBlock:^(id returnValue) {
                
            } failureBlock:^(NSError *error) {
                
            }];
        }else if ([arr[indexPath.section][indexPath.row] isEqualToString:@"关于上位"]) {
            UIStoryboard *storyboad = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            AboutViewController *aboutVC = [storyboad instantiateViewControllerWithIdentifier:@"AboutViewController"];
            [aboutVC setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:aboutVC animated:YES];
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
