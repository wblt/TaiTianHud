//
//  MoreCompanyViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/8.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MoreCompanyViewController.h"
#import "HomeCompanyModel.h"
#import "HomeActivityModel.h"
@interface MoreCompanyViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSInteger page;
}
@property (nonatomic,copy) NSMutableArray * companyArr;
@end

@implementation MoreCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"所有公司";
    _companyArr = @[].mutableCopy;
    [self initUI];
    [self requestData];
}

#pragma mark -  初始化页面
-(void)initUI{
    page = 1;
    self.tableView.mj_header.hidden = NO;
    self.tableView.mj_footer.hidden = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self.tableView reloadData];
}

- (void)requestData
{
    if (_type == 1) {
        [NetRequestClass afn_requestURL:@"appComMore" httpMethod:@"GET" params:@{@"p":@(page)}.mutableCopy successBlock:^(id returnValue) {
            
            if (page == 1) {
                [_companyArr removeAllObjects];
            }
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                HomeCompanyModel *model = [HomeCompanyModel mj_objectWithKeyValues:dic];
                [arr addObject:model];
            }
            if(_companyArr.count == 0){
                _companyArr = arr;
                [self.tableView.mj_header endRefreshing];
            }else{
                [_companyArr addObjectsFromArray:arr];
                [self.tableView.mj_footer endRefreshing];
            }
            
            if(page >= [returnValue[@"data"][@"maxPage"] integerValue]){
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                page = page + 1;
            }
            [self.tableView reloadData];
        } failureBlock:^(NSError *error) {
            
        }];
    }else {
        [NetRequestClass afn_requestURL:@"appActMore" httpMethod:@"GET" params:@{@"p":@(page)}.mutableCopy successBlock:^(id returnValue) {
            
            if (page == 1) {
                [_companyArr removeAllObjects];
            }
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                HomeActivityModel *model = [HomeActivityModel mj_objectWithKeyValues:dic];
                [arr addObject:model];
            }
            if(_companyArr.count == 0){
                _companyArr = arr;
                [self.tableView.mj_header endRefreshing];
            }else{
                [_companyArr addObjectsFromArray:arr];
                [self.tableView.mj_footer endRefreshing];
            }
            
            if(page >= [returnValue[@"data"][@"maxPage"] integerValue]){
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                page = page + 1;
            }
            [self.tableView reloadData];
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

#pragma mark ————— tableview 代理 —————
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _companyArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ideitifier = @"HomeCompanyTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ideitifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ideitifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (_type == 1) {
        HomeCompanyModel *model = _companyArr[indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"annou_default"]];
        cell.imageView.layer.masksToBounds = YES;
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.trade;
    }else {
        HomeActivityModel *model = _companyArr[indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumb] placeholderImage:[UIImage imageNamed:@"annou_default"]];
        cell.imageView.layer.masksToBounds = YES;
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.com_title;
    }
    return cell;
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
