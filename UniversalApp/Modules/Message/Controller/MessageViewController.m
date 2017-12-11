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
{
    NSInteger page;
}
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    _dataArray = @[].mutableCopy;
    
    [self initUI];
    page = 1;
    [self requestData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    page = 1;
    [self requestData];
}

- (void)requestData
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [NetRequestClass afn_requestURL:@"appMsgList" httpMethod:@"GET" params:@{@"p":@(page), @"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            if (page == 1) {
                [self.tableView.mj_footer setState:MJRefreshStateIdle];
                [_dataArray removeAllObjects];
            }
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                MessageModel *model = [MessageModel mj_objectWithKeyValues:dic];
                [arr addObject:model];
            }
            if(_dataArray.count == 0){
                _dataArray = arr;
                [self.tableView.mj_header endRefreshing];
            }else{
                [_dataArray addObjectsFromArray:arr];
                [self.tableView.mj_footer endRefreshing];
            }
            
            if(page >= [returnValue[@"data"][@"maxPage"] integerValue]){
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                page = page + 1;
            }
            [self.tableView reloadData];
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}


#pragma mark -  初始化页面
-(void)initUI{
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = NO;
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
    cell.time.text = model.suetime;
    cell.text.text = model.title;
    cell.title.text = @"系统消息";
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
    if ([model.ishref integerValue] == 1) {
        if ([model.url length] > 0) {
            RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:nil]];
            loginNavi.title = @"消息详情";
            [self presentViewController:loginNavi animated:YES completion:nil];
        }else {
            if ([model.module isEqualToString:@"artonce"]) {
                [NetRequestClass afn_requestURL:@"appGetArtonce" httpMethod:@"GET" params:@{@"id":model.module_id}.mutableCopy successBlock:^(id returnValue) {
                    if ([returnValue[@"status"] integerValue] == 1) {
                        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:nil orHtml:returnValue[@"data"][@"content"]]];
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
    
    if (lpGR.state == UIGestureRecognizerStateEnded)//手势结束
        
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
                [self.tableView reloadData];
            }else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
            
        } failureBlock:^(NSError *error) {
        }];
        
    }
    
}

-(void)headerRereshing{
    page = 1;
    
    [self requestData];
}

-(void)footerRereshing{
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
