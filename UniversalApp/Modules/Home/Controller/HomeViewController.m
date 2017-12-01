//
//  HomeViewController.m
//  TaitianHud
//
//  Created by wb on 2017/10/19.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "HomeViewController.h"
#import "SDCycleScrollView.h"
#import "GYChangeTextView.h"
#import "UINavigationBar+Awesome.h"
#import "HomeCompanyModel.h"
#import "HomeActivityModel.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "HomeCompanyViewController.h"
#import "HomeBannerModel.h"
#import "MoreCompanyViewController.h"
#import "RootWebViewController.h"
#import "HomeCompanyTableCell.h"
#import "NSString+Extend.h"
#import "HomeStarModel.h"
@interface HomeViewController () <SDCycleScrollViewDelegate, GYChangeTextViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,copy) NSArray * dataArray;
@property (nonatomic,copy) NSMutableArray * bannerArr;
@property (nonatomic,copy) NSMutableArray * companyArr;
@property (nonatomic,copy) NSMutableArray * activityArr;
@property (nonatomic,copy) NSMutableArray * starArr;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    _bannerArr = @[].mutableCopy;
    _companyArr = @[].mutableCopy;
    _activityArr = @[].mutableCopy;
    _starArr = @[].mutableCopy;
    //self.dataArray = @[tags,webView,emitterView,IAPPay,tabarBadge,share,alert,action,status,NavColor,JSCore,scrollBanner];
    
    [self initUI];
    [self requestData];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
}

- (void)requestData
{
    [NetRequestClass afn_requestURL:@"appIndexlist" httpMethod:@"GET" params:nil successBlock:^(id returnValue) {
        for (NSDictionary *dic in returnValue[@"data"][@"admarket"]) {
            HomeBannerModel *model = [HomeBannerModel mj_objectWithKeyValues:dic];
            [_bannerArr addObject:model];
        }
        for (NSDictionary *dic in returnValue[@"data"][@"company"]) {
            HomeCompanyModel *model = [HomeCompanyModel mj_objectWithKeyValues:dic];
            [_companyArr addObject:model];
        }
        
        for (NSDictionary *dic in returnValue[@"data"][@"activity"]) {
            HomeActivityModel *model = [HomeActivityModel mj_objectWithKeyValues:dic];
            [_activityArr addObject:model];
        }
        
        for (NSDictionary *dic in returnValue[@"data"][@"star"]) {
            HomeStarModel *model = [HomeStarModel mj_objectWithKeyValues:dic];
            [_starArr addObject:model];
        }
        
        [self.tableView reloadData];
    } failureBlock:^(NSError *error) {
        
    }];
}


#pragma mark -  初始化页面
-(void)initUI{
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HomeCompanyTableCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = CGRectMake(0, -38, KScreenWidth, KScreenHeight-49);
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeCompanyTableCell" bundle:nil] forCellReuseIdentifier:@"HomeCompanyTableCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView reloadData];
}

#pragma mark ————— tableview 代理 —————
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _activityArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 240.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeCompanyTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCompanyTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HomeActivityModel *model = _activityArr[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 400+150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"HomeHeadView" owner:self options:nil] lastObject];
    
    SDCycleScrollView *cycleScrollView3 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, KScreenWidth, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cycleScrollView3.currentPageDotImage = [UIImage imageNamed:@"pageControlCurrentDot"];
    cycleScrollView3.pageDotImage = [UIImage imageNamed:@"pageControlDot"];
    NSMutableArray *arr = @[].mutableCopy;
    for (HomeBannerModel *model in _bannerArr) {
        [arr addObject:model.img];
    }
    cycleScrollView3.imageURLStringsGroup = arr;
    
    [view addSubview:cycleScrollView3];
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, cycleScrollView3.bottom, KScreenWidth, 1)];
    line1.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line1];
    
//    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(15, line1.bottom+10, 35, 25)];
//    [img setImage:[UIImage imageNamed:@"2"]];
//    img.contentMode = UIViewContentModeScaleAspectFit;
//    [view addSubview:img];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, line1.bottom-20, KScreenWidth-40, 50)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"🔍搜索你想要知道的内容";
    [view addSubview:textField];
//    GYChangeTextView *tView = [[GYChangeTextView alloc] initWithFrame:CGRectMake(60, line1.bottom, KScreenWidth-60-15, 45)];
//    tView.delegate = self;
//    [view addSubview:tView];
//    [tView animationWithTexts:[NSArray arrayWithObjects:@"这是第1条",@"这是第2条",@"这是第3条", nil]];
//    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, tView.bottom, KScreenWidth, 1)];
//    line2.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [view addSubview:line2];
    for (int i = 0; i < _companyArr.count; i++) {
        HomeCompanyModel *model = _companyArr[i];
        CGFloat w = (KScreenWidth-70*4)/5;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w+i*(70+w), textField.bottom+20, 70, 70)];
        btn.tag = 201+i;
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn sd_setImageWithURL:[NSURL URLWithString:model.img[0]] forState:0];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btn addTapBlock:^(UIButton *btn) {
            HomeCompanyViewController *vc = [[HomeCompanyViewController alloc] init];
            vc.model = _companyArr[btn.tag-201];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [view addSubview:btn];
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(w+i*(70+w), btn.bottom+8, 70, 25)];
        btnLabel.text = model.abbtion;
        btnLabel.textColor = [UIColor blackColor];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        btnLabel.font = [UIFont systemFontOfSize:15];
        [view addSubview:btnLabel];
    }
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 350, KScreenWidth, 10)];
    line3.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line3];
   
    for (int i = 0; i < _starArr.count; i++) {
        HomeStarModel *model = _starArr[i];
        CGFloat w = (KScreenWidth-70*4)/5;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w+i*(70+w), line3.bottom+20, 70, 70)];
        btn.tag = 301+i;
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn sd_setImageWithURL:[NSURL URLWithString:model.img] forState:0];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btn addTapBlock:^(UIButton *btn) {
        
            //明星
        }];
        [view addSubview:btn];
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(w+i*(70+w), btn.bottom+8, 70, 25)];
        btnLabel.text = model.realname;
        btnLabel.textColor = [UIColor blackColor];
        btnLabel.textAlignment = NSTextAlignmentCenter;
        btnLabel.font = [UIFont systemFontOfSize:15];
        [view addSubview:btnLabel];
    }
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 360+140, KScreenWidth, 10)];
    line4.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line4];
    
    UIButton *more = [view viewWithTag:500];
    [more addTapBlock:^(UIButton *btn) {
        MoreCompanyViewController *vc = [[MoreCompanyViewController alloc] init];
        vc.type = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIButton *moreAct = [view viewWithTag:501];
    [moreAct addTapBlock:^(UIButton *btn) {
        MoreCompanyViewController *vc = [[MoreCompanyViewController alloc] init];
        vc.type = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}

#pragma mark -  scrollview回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"点击了第%ld个",index);
    HomeBannerModel *model = _bannerArr[index];
    RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url]];
    [self presentViewController:loginNavi animated:YES completion:nil];
}

- (void)gyChangeTextView:(GYChangeTextView *)textView didTapedAtIndex:(NSInteger)index {
    NSLog(@"%ld",index);
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
