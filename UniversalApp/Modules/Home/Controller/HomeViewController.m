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
#import "MoreActivityViewController.h"
#import "SearchActivityViewController.h"
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toSearchActivity)];
    
    [self initUI];
    [self requestData];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
}

- (void)toSearchActivity {
    SearchActivityViewController *search = [[SearchActivityViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
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
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-49-64);
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
    [cell.time setTitle:[NSString timeWithTimeIntervalString:model.start] forState:0];
    cell.titleLabel.text = [NSString stringWithFormat:@"  %@", model.title];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 830;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 830)];
    view.backgroundColor = [UIColor whiteColor];
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
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20, line1.bottom-20, KScreenWidth-40, 50)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"🔍搜索你想要知道的内容";
    textField.font = [UIFont systemFontOfSize:15];
    [view addSubview:textField];
    for (int i = 0; i < _companyArr.count; i++) {
        HomeCompanyModel *model = _companyArr[i];
        CGFloat w = (KScreenWidth-70*4)/5;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w+i*(70+w), textField.bottom+20, 70, 70)];
        btn.tag = 201+i;
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn sd_setImageWithURL:[NSURL URLWithString:model.thumb] forState:0];
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
    
    UIButton *starL = [[UIButton alloc] initWithFrame:CGRectMake(15, line3.bottom, 80, 40)];
    starL.titleLabel.font = [UIFont systemFontOfSize:14];
    [starL setTitleColor:[UIColor blackColor] forState:0];
    [starL setTitle:@"明星学员" forState:0];
    [starL setImage:[UIImage imageNamed:@"首页活动"] forState:0];
    [view addSubview:starL];
    
    UIButton *moreStar = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth-15-40, line3.bottom, 40, 40)];
    moreStar.titleLabel.font = [UIFont systemFontOfSize:13];
    [moreStar setTitleColor:[UIColor lightGrayColor] forState:0];
    [moreStar setTitle:@"更多" forState:0];
    [moreStar setImage:[UIImage imageNamed:@"genduo"] forState:0];
    [moreStar addTapBlock:^(UIButton *btn) {
        //更多明星
    }];
    [view addSubview:moreStar];
   
    for (int i = 0; i < _starArr.count; i++) {
        HomeStarModel *model = _starArr[i];
        CGFloat w = 10;
        NSInteger y = i/2;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w+i%2*((KScreenWidth-30)/2+w), starL.bottom+(180+10)*y, (KScreenWidth-30)/2, 180)];
        btn.tag = 301+i;
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn addTapBlock:^(UIButton *btn) {
        
            //明星
        }];
        [view addSubview:btn];
        
        UIImageView *starImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btn.width, 120)];
        [starImg sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        starImg.layer.cornerRadius = 5;
        starImg.layer.masksToBounds = YES;
        starImg.contentMode = UIViewContentModeScaleAspectFill;
        [btn addSubview:starImg];
        
        UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, btn.height-30, btn.width-20, 30)];
        btnLabel.text = model.realname;
        btnLabel.textColor = [UIColor darkGrayColor];
        btnLabel.textAlignment = NSTextAlignmentLeft;
        btnLabel.font = [UIFont systemFontOfSize:13];
        [btn addSubview:btnLabel];
        UILabel *btnTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, starImg.bottom+5, btn.width-20, btnLabel.top-starImg.bottom-5)];
        btnTitle.text = model.title;
        btnTitle.textColor = [UIColor blackColor];
        btnTitle.textAlignment = NSTextAlignmentLeft;
        btnTitle.font = [UIFont systemFontOfSize:15];
        btnTitle.numberOfLines = 0;
        [btn addSubview:btnTitle];
    }
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 780, KScreenWidth, 10)];
    line4.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line4];
    
    UIButton *ipL = [[UIButton alloc] initWithFrame:CGRectMake(15, line4.bottom, 60, 40)];
    ipL.titleLabel.font = [UIFont systemFontOfSize:14];
    [ipL setTitleColor:[UIColor blackColor] forState:0];
    [ipL setTitle:@"经典ip" forState:0];
    [ipL setImage:[UIImage imageNamed:@"经典案例"] forState:0];
    [view addSubview:ipL];
    UIView *line5 = [[UIView alloc] initWithFrame:CGRectMake(0, ipL.bottom, KScreenWidth, 1)];
    line5.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [view addSubview:line5];

    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth-15-40, line4.bottom, 40, 40)];
    more.titleLabel.font = [UIFont systemFontOfSize:13];
    [more setTitleColor:[UIColor lightGrayColor] forState:0];
    [more setTitle:@"更多" forState:0];
    [more setImage:[UIImage imageNamed:@"genduo"] forState:0];
    [more addTapBlock:^(UIButton *btn) {
        MoreActivityViewController *vc = [[MoreActivityViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [view addSubview:more];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeActivityModel *model = _activityArr[indexPath.row];
    RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:nil]];
    [self presentViewController:loginNavi animated:YES completion:nil];
}

#pragma mark -  scrollview回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"点击了第%ld个",index);
    HomeBannerModel *model = _bannerArr[index];
    if ([model.url length]>0||[model.module length]>0) {
        RootNavigationController *loginNavi =[[RootNavigationController alloc] initWithRootViewController:[[RootWebViewController alloc] initWithUrl:model.url orHtml:model.module]];
        [self presentViewController:loginNavi animated:YES completion:nil];
    }
    
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
