//
//  ChongzhiViewController.m
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "ChongzhiViewController.h"
#import "ChongzhiCollectionCell.h"
#import "ChongzhiPayModel.h"
@interface ChongzhiViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) ChongzhiPayModel *selectModel;

@end

@implementation ChongzhiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值";
    _arr = @[].mutableCopy;
    //注册cell
    self.collectionView.bounces = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChongzhiCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"ChongzhiCollectionCell"];
    //设置数据源代理
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.mj_header.hidden = YES;
    self.collectionView.mj_footer.hidden = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(118, 0, 0, 0);
    [self.view addSubview:self.collectionView];
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake((KScreenWidth-60)/3, 70);
    UIButton *czBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, KScreenHeight-80-64, KScreenWidth-40, 48)];
    czBtn.backgroundColor = [UIColor orangeColor];
    [czBtn setTitle:@"充  值" forState:0];
    czBtn.layer.cornerRadius = 3;
    czBtn.layer.masksToBounds = YES;
    
    [self.view addSubview:czBtn];
    [czBtn addTapBlock:^(UIButton *btn) {
        if (_selectModel == nil) {
            [SVProgressHUD showErrorWithStatus:@"请选择充值数量调充值url"];
        }else {
            [SVProgressHUD showErrorWithStatus:@"调充值url"];
        }
    }];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -118, KScreenWidth, 118)];
    view.backgroundColor = [UIColor clearColor];
    [self.collectionView addSubview:view];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 10, KScreenWidth, 50)];
    v.backgroundColor = [UIColor whiteColor];
    [view addSubview:v];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, KScreenWidth/2, 50)];
    name.font = [UIFont systemFontOfSize:15];
    name.text = self.nameText;
    [view addSubview:name];
    UILabel *jifen = [[UILabel alloc] initWithFrame:CGRectMake(name.right, 10, KScreenWidth-name.right-20, 50)];
    jifen.text = [NSString stringWithFormat:@"%@积分", self.jifenText];
    jifen.font = [UIFont systemFontOfSize:15];
    jifen.textAlignment = NSTextAlignmentRight;
    [view addSubview:jifen];
    
    UILabel *headTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, name.bottom+10, KScreenWidth, 48)];
    headTitle.text = @"请选择充值数量";
    headTitle.font = [UIFont systemFontOfSize:15];
    headTitle.backgroundColor = [UIColor whiteColor];
    headTitle.textAlignment = NSTextAlignmentCenter;
    [view addSubview:headTitle];
    
    [self requestData];
}

- (void)requestData
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [NetRequestClass afn_requestURL:@"appRecharge" httpMethod:@"GET" params:@{@"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            for (NSDictionary *dic in returnValue[@"data"][@"list"]) {
                ChongzhiPayModel *model = [ChongzhiPayModel mj_objectWithKeyValues:dic];
                [_arr addObject:model];
            }
            self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, (_arr.count/3+_arr.count%3==0?0:1)*80+118+40);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.collectionView.bottom, 110, 30)];
            label.text = @"其他数量";
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:14];
            [self.view addSubview:label];
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(140, self.collectionView.bottom, KScreenWidth-200, 30)];
            field.keyboardType = UIKeyboardTypeNumberPad;
            field.backgroundColor = [UIColor whiteColor];
            field.borderStyle = UITextBorderStyleRoundedRect;
            [self.view addSubview:field];
            [self.collectionView reloadData];
            [self performSelector:@selector(actionHHHHH) withObject:nil afterDelay:0];
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)actionHHHHH
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChongzhiCollectionCell *cell = (ChongzhiCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ChongzhiCollectionCell" forIndexPath:indexPath];
    ChongzhiPayModel *model = _arr[indexPath.row];
    cell.jifen.text = [NSString stringWithFormat:@"%@ 积分", model.jifen];
    cell.money.text = [NSString stringWithFormat:@"￥ %@", model.money_real];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChongzhiCollectionCell *cell = (ChongzhiCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    for (ChongzhiCollectionCell *c in collectionView.visibleCells) {
        c.backgroundColor = [UIColor whiteColor];
        c.jifen.textColor = [UIColor blackColor];
        c.money.textColor = [UIColor blackColor];
    }
    _selectModel = _arr[indexPath.row];
    cell.backgroundColor = [UIColor orangeColor];
    cell.jifen.textColor = [UIColor whiteColor];
    cell.money.textColor = [UIColor whiteColor];
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
