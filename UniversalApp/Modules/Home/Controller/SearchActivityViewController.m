//
//  SearchActivityViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/12/6.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "SearchActivityViewController.h"
#import "SDCycleScrollView.h"
#import "UINavigationBar+Awesome.h"
#import "HomeCompanyModel.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "HomeActivityModel.h"
#import "HomeCompanyTableCell.h"
#import "NSString+Extend.h"
#import "RootWebViewController.h"
@interface SearchActivityViewController () <SDCycleScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, UITextFieldDelegate>
{
    UIWebView *webView;
    NSInteger page;
    UITextField *textField;
}
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation SearchActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"活动搜索";
    _dataArray = @[].mutableCopy;
    
    [self initUI];
    page = 1;
    [self requestData:@""];
}

- (void)requestData:(NSString *)key
{
    [NetRequestClass afn_requestURL:@"appSearchAct" httpMethod:@"GET" params:@{@"p": @(page),@"keywords":key}.mutableCopy successBlock:^(id returnValue) {
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
    
    [self.tableView reloadData];
}

#pragma mark ————— tableview 代理 —————
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 240.0f;
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
    [cell.time setTitle:[NSString timeWithTimeIntervalString:model.start] forState:0];
    cell.titleLabel.text = [NSString stringWithFormat:@"  %@", model.title];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeActivityModel *model = _dataArray[indexPath.row];
    RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:nil]];
    [self presentViewController:loginNavi animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (textField == nil) {
        textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, KScreenWidth-80, 30)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.backgroundColor = [UIColor whiteColor];
        textField.font = [UIFont systemFontOfSize:14];
        textField.delegate = self;
        
    }
    [view addSubview:textField];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(textField.right, 10, 60, 30)];
    [btn setTitle:@"搜索" forState:0];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTapBlock:^(UIButton *btn) {
        [textField resignFirstResponder];
        page = 1;
        [self requestData:textField.text];
    }];
    [view addSubview:btn];
    return view;
}

-(void)headerRereshing{
    page = 1;
    [self.tableView.mj_footer setState:MJRefreshStateIdle];
    [self requestData:textField.text];
}

-(void)footerRereshing{
    [self requestData:textField.text];
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
