//
//  HomeCompanyViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "HomeCompanyViewController.h"
#import "SDCycleScrollView.h"
#import "UINavigationBar+Awesome.h"
#import "HomeCompanyModel.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "HomeActivityModel.h"
#import "HomeCompanyTableCell.h"
#import "NSString+Extend.h"
#import "RootWebViewController.h"
@interface HomeCompanyViewController () <SDCycleScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
{
    UIWebView *webView;
}
@property (nonatomic,copy) NSMutableArray * dataArray;
@end

@implementation HomeCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"公司详情";
    _dataArray = @[].mutableCopy;
    
    [self initUI];
    [self requestData];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
}

- (void)requestData
{
    [NetRequestClass afn_requestURL:@"appComDetail" httpMethod:@"GET" params:@{@"id": _model.company_id}.mutableCopy successBlock:^(id returnValue) {
       _model = [HomeCompanyModel mj_objectWithKeyValues:returnValue[@"data"]];

        for (NSDictionary *dic in returnValue[@"data"][@"activity"][@"list"]) {
            HomeActivityModel *aModel = [HomeActivityModel mj_objectWithKeyValues:dic];
            [_dataArray addObject:aModel];
        }
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        
    }];
}


#pragma mark -  初始化页面
-(void)initUI{
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.bounces = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeCompanyTableCell" bundle:nil] forCellReuseIdentifier:@"HomeCompanyTableCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(160, 0, 0, 0);
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"CompanyDetailHeadView" owner:self options:nil] lastObject];
    UIImageView *img = [view viewWithTag:202];
    [img sd_setImageWithURL:[NSURL URLWithString:_model.thumb] placeholderImage:[UIImage imageNamed:@"annou_default"]];
    
    UILabel *label1 = [view viewWithTag:203];
    label1.text = _model.title;
    UILabel *label2 = [view viewWithTag:204];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"关注人数：%@", _model.collect]];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor orangeColor]
                range:NSMakeRange(5,[_model.collect length])];
    label2.attributedText = str;
    
    UILabel *label3 = [view viewWithTag:205];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"活动数量：%@", _model.act_num]];
    [str1 addAttribute:NSForegroundColorAttributeName
                value:[UIColor orangeColor]
                range:NSMakeRange(5,[_model.act_num length])];
    label3.attributedText = str1;
    view.frame = CGRectMake(0, -160, KScreenWidth, 160);
    [self.tableView addSubview:view];
    [self.tableView reloadData];
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
