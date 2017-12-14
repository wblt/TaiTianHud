//
//  ActivityViewController.m
//  TaitianHud
//
//  Created by wb on 2017/10/19.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "ActivityViewController.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "HomeCompanyTableCell.h"
#import "HomeActivityModel.h"
#import "RootWebViewController.h"
#import "NSString+Extend.h"
#import "LoginViewController.h"
#import <UMSocialCore/UMSocialCore.h>
@interface ActivityViewController () <UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    NSString *type;
    NSInteger page;
    UITextField *textField;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentV;
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.segmentV;
    _dataArray = @[].mutableCopy;
    [_segmentV addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toSearch)];
    [self initUI];
    page = 1;
    type = @"start";
    [self requestDataType:@"start" keyword:@""];
   
}

- (void)toSearch
{
    UIView *v = [[UIView alloc] initWithFrame:self.view.window.bounds];
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    UIView *statue = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
    statue.backgroundColor = [UIColor grayColor];
    [v addSubview:statue];
    //导航条的搜索条
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f,20.0f,KScreenWidth,44.0f)];
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    [searchBar setPlaceholder:@"搜索"];
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.tintColor = [UIColor blackColor];
    [v addSubview:searchBar];
    [self.view.window addSubview:v];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [v removeFromSuperview];
    }];
    [v addGestureRecognizer:tap];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar.superview removeFromSuperview];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    page = 1;
    [self requestDataType:type keyword:searchBar.text];
    [searchBar.superview removeFromSuperview];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    switch (Index) {
        case 0:
            type = @"start";
            break;
        case 1:
            type = @"notstart";
            break;
        case 2:
            type = @"end";
            break;
        default:
            break;
    }
    [_dataArray removeAllObjects];
    page = 1;
    [self requestDataType:type keyword:textField.text];
}

- (void)requestDataType:(NSString *)typeStr keyword:(NSString *)word
{
    [NetRequestClass afn_requestURL:@"appActList" httpMethod:@"GET" params:@{@"p":@(page), @"type":typeStr,@"keywords":word}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            if (page == 1) {
                [self.tableView.mj_footer resetNoMoreData];
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
            if (_dataArray.count == 0) {
                [SVProgressHUD showErrorWithStatus:@"暂无数据"];
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
    return 210.0f;
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
        [self requestDataType:type keyword:textField.text];
    }];
    [view addSubview:btn];
    return view;
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
    [cell.time setTitle:[NSString timeWithTimeIntervalString:model.start] forState:0];
    cell.titleLabel.text = [NSString stringWithFormat:@"  %@", model.title];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeActivityModel *model = _dataArray[indexPath.row];
    
    UserModel *u = [[UserConfig shareInstace] getAllInformation];
    if (u.wx_openid==nil||[u.wx_openid length] == 0) {
        if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        [self AlertWithTitle:@"温馨提示" message:@"需授权微信" andOthers:@[@"取消",@"同意"] animated:YES action:^(NSInteger index) {
            if (index == 1) {
                [userManager loginWithActivityDetailCompletion:^(BOOL success, NSString *des) {
                    if (success) {
                        UserModel *user = [[UserConfig shareInstace] getAllInformation];
                        NSString *urlStr = [NSString stringWithFormat:@"%@?nickname=%@&headimgurl=%@&openid=%@&sex=%@&deviceid=%@&ub_id=%@&source=app", model.url, user.nickname,user.headpic,user.wx_openid,user.sex,[[NSUUID UUID] UUIDString],user.ub_id];
                        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] orHtml:nil]];
                        
                        [self presentViewController:loginNavi animated:YES completion:nil];
                    }
                }];
            }
        }];
        }
    }else {
        UserModel *user = [[UserConfig shareInstace] getAllInformation];
        NSString *urlStr = [NSString stringWithFormat:@"%@?nickname=%@&headimgurl=%@&openid=%@&sex=%@&deviceid=%@&ub_id=%@&source=app", model.url, user.nickname,user.headpic,user.wx_openid,user.sex,[[NSUUID UUID] UUIDString],user.ub_id];
        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] orHtml:nil]];
        
        [self presentViewController:loginNavi animated:YES completion:nil];
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    
}

-(void)headerRereshing{
    page = 1;
    [self requestDataType:type keyword:@""];
}

-(void)footerRereshing{
    [self requestDataType:type keyword:@""];
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
