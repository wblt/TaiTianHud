//
//  MyPacketViewController.m
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MyPacketViewController.h"
#import "MyTaskCell.h"
#import "ChongzhiModel.h"
#import "ChongzhiViewController.h"
@interface MyPacketViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *arr;
    NSInteger page;
}

@end

@implementation MyPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的钱包";
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.frame = CGRectMake(0, 160, KScreenWidth, self.view.height-160);
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyTaskCell" bundle:nil] forCellReuseIdentifier:@"MyTaskCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"MyPacketHeadView" owner:self options:nil] lastObject];
    v.backgroundColor = [UIColor whiteColor];
    v.frame = CGRectMake(0, 0, KScreenWidth, 160+64);
    
    UIButton *chongzhi = (UIButton *)[v viewWithTag:202];
    chongzhi.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    chongzhi.layer.borderWidth = 1;
    [chongzhi addTapBlock:^(UIButton *btn) {
        UserModel *model = [[UserConfig shareInstace] getAllInformation];
        UILabel *money = (UILabel *)[self.view viewWithTag:201];
        ChongzhiViewController *cz = [[ChongzhiViewController alloc] init];
        cz.nameText = model.nickname;
        cz.jifenText = money.text;
        [self.navigationController pushViewController:cz animated:YES];
    }];
    [self.view addSubview:v];
    arr = @[].mutableCopy;
    page = 1;
    [self requestData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTaskCell *cell = (MyTaskCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTaskCell" forIndexPath:indexPath];
    ChongzhiModel *model = arr[indexPath.row];
    cell.titleLabel.text = model.title;
    cell.detailTitle.text = model.adddate;
    cell.typeLabel.hidden = NO;
    if ([model.source integerValue] == 1) {
        cell.typeLabel.text = @" 充值 ";
        cell.typeLabel.backgroundColor = [UIColor colorWithHexString:@"0080FF"];
    }else if ([model.source integerValue] == 2) {
        cell.typeLabel.text = @" 任务奖励 ";
        cell.typeLabel.backgroundColor = [UIColor orangeColor];
    }else {
        cell.typeLabel.text = @" 其他 ";
        cell.typeLabel.backgroundColor = [UIColor colorWithHexString:@"008040"];
    }
    [cell.receiveBtn setTitle:[NSString stringWithFormat:@"+%@",model.usefee] forState:0];
    cell.receiveBtn.userInteractionEnabled = NO;
    cell.receiveBtn.backgroundColor = [UIColor clearColor];
    [cell.receiveBtn setTitleColor:[UIColor orangeColor] forState:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    view.backgroundColor = [UIColor whiteColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 10)];
    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 120, 30)];
    [btn setTitle:@" 我的充值记录" forState:0];
    [btn setImage:[UIImage imageNamed:@"充值记录"] forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    btn.userInteractionEnabled = NO;
    [view addSubview:btn];
    return view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.StatusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navImage"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:CNavBgFontColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :CNavBgFontColor, NSFontAttributeName : [UIFont systemFontOfSize:18]}];
}

- (void)requestData
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [SVProgressHUD showWithStatus:@"加载中..."];
    [NetRequestClass afn_requestURL:@"appMyWallet" httpMethod:@"GET" params:@{@"ub_id":model.ub_id, @"p":@(page)}.mutableCopy successBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        if ([returnValue[@"status"] integerValue] == 1) {
            if (page == 1) {
                [arr removeAllObjects];
            }
            NSMutableArray *list = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                ChongzhiModel *model = [ChongzhiModel mj_objectWithKeyValues:dic];
                [list addObject:model];
            }
            if(arr.count == 0){
                arr = list;
                [self.tableView.mj_header endRefreshing];
            }else{
                [arr addObjectsFromArray:list];
                [self.tableView.mj_footer endRefreshing];
            }
            
            if(page >= [returnValue[@"data"][@"maxPage"] integerValue]){
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                page = page + 1;
            }
            UILabel *money = (UILabel *)[self.view viewWithTag:201];
            money.text = [NSString stringWithFormat:@"%@", returnValue[@"data"][@"totaljifen"]];
            [self.tableView reloadData];
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
