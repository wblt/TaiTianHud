//
//  MoreStarViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/12/7.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MoreStarViewController.h"
#import "MoreStarCollectionCell.h"
#import "HomeStarModel.h"
@interface MoreStarViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSInteger page;
}

@property (nonatomic, strong) NSMutableArray *arr;

@end

@implementation MoreStarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更多学员";
    _arr = @[].mutableCopy;
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"MoreStarCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MoreStarCollectionCell"];
    //设置数据源代理
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.mj_header.hidden = NO;
    self.collectionView.mj_footer.hidden = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((KScreenWidth-30)/2, 60+(KScreenWidth-30)/2);
    page = 1;
    [self requestData];
}

- (void)requestData
{
    [NetRequestClass afn_requestURL:@"appStarMore" httpMethod:@"GET" params:@{@"p":@(page)}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            
            if (page == 1) {
                [self.collectionView.mj_footer resetNoMoreData];
                [_arr removeAllObjects];
            }
            NSMutableArray *arr = @[].mutableCopy;
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                HomeStarModel *model = [HomeStarModel mj_objectWithKeyValues:dic];
                [arr addObject:model];
            }
            if(_arr.count == 0){
                _arr = arr;
                [self.collectionView.mj_header endRefreshing];
            }else{
                [_arr addObjectsFromArray:arr];
                [self.collectionView.mj_footer endRefreshing];
            }
            
            if(page >= [returnValue[@"data"][@"maxPage"] integerValue]){
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                page = page + 1;
            }
            [self.collectionView reloadData];
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MoreStarCollectionCell *cell = (MoreStarCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MoreStarCollectionCell" forIndexPath:indexPath];
    HomeStarModel *model = _arr[indexPath.row];
    [cell.img sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.title.text = model.title;
    cell.name.text = model.realname;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)headerRereshing{
    page = 1;
    
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
