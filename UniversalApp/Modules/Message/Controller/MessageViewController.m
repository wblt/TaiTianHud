//
//  MessageViewController.m
//  TaitianHud
//
//  Created by wb on 2017/10/19.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "MessageViewController.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "MessageCell.h"
#import "MessageModel.h"
#import "RootWebViewController.h"
#import "NSString+Extend.h"
@interface MessageViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    
    
    [self initUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage) name:@"NewMessageNotification" object:nil];
}

- (void)receiveNewMessage
{
    [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UserModel *user = [[UserConfig shareInstace] getAllInformation];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataArray] forKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.navigationController.tabBarItem.badgeValue integerValue] forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)requestData
{
    UserModel *user = [[UserConfig shareInstace] getAllInformation];
    _dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]]];
    NSInteger noReadCount=0;
    for (MessageModel *m in _dataArray) {
        if ([m.isread integerValue]!=1) {
            noReadCount += 1;
        }
    }
    if (noReadCount > 0) {
        [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",noReadCount]];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataArray] forKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] setInteger:[self.navigationController.tabBarItem.badgeValue integerValue] forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NetRequestClass afn_requestURL:@"appMsgList" httpMethod:@"GET" params:@{@"ub_id":user.ub_id}.mutableCopy successBlock:^(id returnValue) {
         [self.tableView.mj_header endRefreshing];
        if ([returnValue[@"status"] integerValue] == 1) {
           
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"]) {
                MessageModel *model = [MessageModel mj_objectWithKeyValues:dic];
                [arr addObject:model];
            }
            if(_dataArray.count == 0){
                _dataArray = arr;
               
            }else{
                NSMutableArray *hhh = @[].mutableCopy;
                for (MessageModel *m in _dataArray) {
                    for (MessageModel *h in arr) {
                        if ([m.msg_id isEqualToString:h.msg_id]) {
                            [hhh addObject:m];
                        }
                    }
                }
                for (MessageModel *qq in hhh) {
                    [_dataArray removeObject:qq];
                }
                for (MessageModel *m in _dataArray) {
                    m.isread = @"1";
                }
                NSArray *sortedArray = [_dataArray sortedArrayUsingComparator:^NSComparisonResult(MessageModel *mA, MessageModel *mB) {
                    
                    return [mB.suetime compare:mA.suetime];
                }];
                
                [arr addObjectsFromArray:sortedArray];
                _dataArray = arr;
            }
            NSInteger noReadCount=0;
            for (MessageModel *m in _dataArray) {
                if ([m.isread integerValue]!=1) {
                    noReadCount += 1;
                }
            }
            if (noReadCount > 0) {
                [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",noReadCount]];
            }
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataArray] forKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
            [[NSUserDefaults standardUserDefaults] setInteger:[self.navigationController.tabBarItem.badgeValue integerValue] forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tableView reloadData];
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

//- (NSArray *)sortedWithNSSortDescriptor:(NSArray *)originArray {
//
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"birthDate" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//
//    return [originArray sortedArrayUsingDescriptors:sortDescriptors];
//}

#pragma mark -  初始化页面
-(void)initUI{
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-49-64);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self showNoDataImage];
    [self.tableView reloadData];
}

#pragma mark ————— tableview 代理 —————
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataArray.count == 0) {
        [self showNoDataImage];
    }else {
        [self removeNoDataImage];
    }
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = _dataArray[indexPath.row];
    CGSize titleSize = [model.title sizeForFont:[UIFont systemFontOfSize:14] size:CGSizeMake(KScreenWidth-22*2-60-8, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    if (titleSize.height+42+5>120) {
        return titleSize.height+42+5;
    }
    return 120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MessageModel *model = _dataArray[indexPath.row];
    [cell.img sd_setImageWithURL:[NSURL URLWithString:model.icon]  placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.time.text = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",[model.suetime integerValue]*1000]];
    cell.text.text = model.title;
    cell.title.text = model.mc_id;
    if ([model.isread integerValue] == 1) {
        cell.redBadge.hidden = YES;
    }else {
        cell.redBadge.hidden = NO;
    }
    cell.tag = indexPath.row + 1000;
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(lpGR:)];
    
    [cell addGestureRecognizer:longPressGR];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = _dataArray[indexPath.row];
    UserModel *user = [[UserConfig shareInstace] getAllInformation];
    if ([model.ishref integerValue] == 1) {
        [NetRequestClass afn_requestURL:@"appOperationMsg" httpMethod:@"POST" params:@{@"ub_id":user.ub_id,@"msg_id":model.msg_id,@"type":@"isread"}.mutableCopy successBlock:^(id returnValue) {
            if ([returnValue[@"status"] integerValue] == 1) {
                model.isread = @"1";
                NSInteger noReadCount=0;
                for (MessageModel *m in _dataArray) {
                    if ([m.isread integerValue]!=1) {
                        noReadCount += 1;
                    }
                }
                if (noReadCount > 0) {
                    [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",noReadCount]];
                }
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataArray] forKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] setInteger:[self.navigationController.tabBarItem.badgeValue integerValue] forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.tableView reloadData];
            }else {
                
            }
            
        } failureBlock:^(NSError *error) {
        }];
        if ([model.url length] > 0) {
            RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:nil]];
            loginNavi.title = @"消息详情";
            [self presentViewController:loginNavi animated:YES completion:nil];
        }else {
            if ([model.module isEqualToString:@"artonce"]) {
                [NetRequestClass afn_requestURL:@"appGetArtonce" httpMethod:@"GET" params:@{@"id":(model.module_id!=nil)?model.module_id:@""}.mutableCopy successBlock:^(id returnValue) {
                    if ([returnValue[@"status"] integerValue] == 1) {
                        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:nil orHtml:[NSString stringWithFormat:@"<h1 style=\"font-size: 40px;text-align: center;margin-left: 10%%;width: 80%%;margin-top: 40px;\">%@</h1>%@",returnValue[@"data"][@"title"],returnValue[@"data"][@"content"]]]];
                        loginNavi.title = @"消息详情";
                        [self presentViewController:loginNavi animated:YES completion:nil];
                    }
                } failureBlock:^(NSError *error) {
                    
                }];
            }
        }
        
    }
}

-(void)lpGR:(UILongPressGestureRecognizer *)lpGR

{
    
    if (lpGR.state == UIGestureRecognizerStateBegan)//手势开始
        
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"标记已读", @"删除", nil];
        actionSheet.tag = lpGR.view.tag + 1000;
        [actionSheet showInView:self.view];
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != 2) {
        MessageModel *model = _dataArray[actionSheet.tag-2000];
        UserModel *user = [[UserConfig shareInstace] getAllInformation];
        if (buttonIndex == 0 && [model.isread isEqualToString:@"1"]) {
            [SVProgressHUD showErrorWithStatus:@"此消息已读"];
            return;
        }
        [NetRequestClass afn_requestURL:@"appOperationMsg" httpMethod:@"POST" params:@{@"ub_id":user.ub_id,@"msg_id":model.msg_id,@"type":buttonIndex==0?@"isread":@"isdel"}.mutableCopy successBlock:^(id returnValue) {
            if ([returnValue[@"status"] integerValue] == 1) {
                if (buttonIndex == 0) {
                    model.isread = @"1";
                    
                }else {
                    [_dataArray removeObjectAtIndex:actionSheet.tag-2000];
                }
                NSInteger noReadCount=0;
                for (MessageModel *m in _dataArray) {
                    if ([m.isread integerValue]!=1) {
                        noReadCount += 1;
                    }
                }
                if (noReadCount > 0) {
                    [self.navigationController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%ld",noReadCount]];
                }
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataArray] forKey:[NSString stringWithFormat:@"%@_Message",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] setInteger:[self.navigationController.tabBarItem.badgeValue integerValue] forKey:[NSString stringWithFormat:@"%@_badge",user.ub_id]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.tableView reloadData];
            }else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
            
        } failureBlock:^(NSError *error) {
        }];
        
    }
    
}

-(void)headerRereshing{
    [self requestData];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:0];
//    }];
//    deleteAction.backgroundColor = [UIColor redColor];
//
//    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"标记已读" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        [self editActionsForRowAtIndexPath:indexPath actionIndex:1];
//    }];
//    blackAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
//
//    return @[deleteAction, blackAction];
//}
//
//#pragma mark - Action
//
//- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
//{
//    MessageModel *model = _dataArray[indexPath.row];
//    UserModel *user = [[UserConfig shareInstace] getAllInformation];
//    if (buttonIndex == 1 && [model.isread isEqualToString:@"1"]) {
//        [SVProgressHUD showErrorWithStatus:@"此消息已读"];
//        return;
//    }
//    [NetRequestClass afn_requestURL:@"appOperationMsg" httpMethod:@"POST" params:@{@"ub_id":user.ub_id,@"msg_id":model.msg_id,@"type":buttonIndex==1?@"isread":@"isdel"}.mutableCopy successBlock:^(id returnValue) {
//        if ([returnValue[@"status"] integerValue] == 1) {
//            if (buttonIndex == 1) {
//                model.isread = @"1";
//            }else {
//                [_dataArray removeObjectAtIndex:indexPath.row];
//            }
//            [self.tableView reloadData];
//        }else {
//            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
//        }
//
//    } failureBlock:^(NSError *error) {
//    }];
//}

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
