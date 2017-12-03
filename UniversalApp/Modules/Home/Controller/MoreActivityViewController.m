//
//  MoreActivityViewController.m
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/3.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MoreActivityViewController.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "HomeCompanyTableCell.h"
#import "HomeActivityModel.h"
#import "RootWebViewController.h"
#import "NSString+Extend.h"
@interface MoreActivityViewController () <UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate>
{
    NSInteger page;
}
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation MoreActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"经典ip";
    _dataArray = @[].mutableCopy;
    
    [self initUI];
    page = 1;
    [self requestData];
    
}

- (void)requestData
{
    [NetRequestClass afn_requestURL:@"appActMore" httpMethod:@"GET" params:@{@"p":@(page)}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            if (page == 1) {
                [_dataArray removeAllObjects];
            }
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                HomeActivityModel *model = [HomeActivityModel mj_objectWithKeyValues:dic];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeCompanyTableCell" bundle:nil] forCellReuseIdentifier:@"HomeCompanyTableCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
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
    return 240.0f;
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
    HomeCompanyTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCompanyTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HomeActivityModel *model = _dataArray[indexPath.row];
    cell.scrollImg.delegate = self;
    cell.scrollImg.placeholderImage = [UIImage imageNamed:@"placeholder"];
    cell.scrollImg.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    cell.scrollImg.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    cell.scrollImg.imageURLStringsGroup = model.img;
    [cell.address setTitle:model.area_title forState:0];
    [cell.personNum setTitle:[NSString stringWithFormat:@"%@人报名",model.total] forState:0];
    [cell.time setTitle:[NSString timeWithTimeIntervalString:model.modtime] forState:0];
    cell.titleLabel.text = [NSString stringWithFormat:@"  %@", model.title];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeActivityModel *model = _dataArray[indexPath.row];
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

