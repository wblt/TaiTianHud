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
@interface MessageViewController () <UITableViewDataSource, UITableViewDelegate>
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

- (void)requestData
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [NetRequestClass afn_requestURL:@"appMsgList" httpMethod:@"GET" params:@{@"p":@(page), @"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            if (page == 1) {
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
    self.tableView.frame = CGRectMake(0, -38, KScreenWidth, KScreenHeight-49-64+38);
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
    CGSize titleSize = [model.title sizeForFont:[UIFont systemFontOfSize:14] size:CGSizeMake(KScreenWidth-40, MAXFLOAT) mode:NSLineBreakByCharWrapping];
    CGFloat imgH = [model.icon length] == 0?0:100;
    CGFloat titleH = [model.msg_id integerValue]==1?18:0;
    return 40+5+titleH+10+imgH+5+titleSize.height+10;
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
    cell.img.height = [model.icon length] == 0?0:100;
    [cell.img sd_setImageWithURL:[NSURL URLWithString:model.icon]  placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.time.text = [NSString timeWithTimeIntervalString:model.readtime];
    cell.text.text = model.title;
    cell.title.height = [model.msg_id integerValue]==1?18:0;
    cell.title.text = [model.msg_id integerValue]==1?@"系统消息":@"";
    cell.line.hidden = [model.msg_id integerValue]==1?NO:YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = _dataArray[indexPath.row];
    RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url]];
    [self presentViewController:loginNavi animated:YES completion:nil];
}


-(void)headerRereshing{
    page = 1;
    [self.tableView.mj_footer setState:MJRefreshStateIdle];
    [self requestData];
}

-(void)footerRereshing{
    [self requestData];
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
