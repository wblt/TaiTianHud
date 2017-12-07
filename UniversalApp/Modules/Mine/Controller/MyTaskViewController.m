//
//  MyTaskViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/30.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MyTaskViewController.h"
#import "MyTaskCell.h"
#import "TaskClassifyModel.h"
#import "TaskModel.h"
@interface MyTaskViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *arr;
}

@end

@implementation MyTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的任务";
    self.tableView.bounces = NO;
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, self.view.height);
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"MyTaskCell" bundle:nil] forCellReuseIdentifier:@"MyTaskCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(140, 0, 0, 0);
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"PersonHeadView" owner:self options:nil] lastObject];
    v.frame = CGRectMake(0, -140, KScreenWidth, 140);
    UIImageView *img = (UIImageView *)[v viewWithTag:201];
    [img sd_setImageWithURL:[NSURL URLWithString:model.headpic] placeholderImage:[UIImage imageNamed:@"friend_default"]];
    UILabel *name = (UILabel *)[v viewWithTag:202];
    name.text = [NSString stringWithFormat:@"%@ • %@", model.nickname, [model.sex integerValue]==1?@"男":@"女"];
    UIButton *bangd = (UIButton *)[v viewWithTag:203];
    bangd.hidden = YES;
    [self.tableView addSubview:v];
    arr = @[].mutableCopy;
    [self requestData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TaskClassifyModel *model = arr[section];
    return model.task.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTaskCell *cell = (MyTaskCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTaskCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    TaskClassifyModel *classifyModel = arr[indexPath.section];
    TaskModel *model = classifyModel.task[indexPath.row];
    cell.titleLabel.text = model.tk_title;
    
    cell.detailTitle.text = [NSString stringWithFormat:@"进度 %d/%@", [model.tl_plan integerValue], model.plan];
    if ([model.status integerValue] == 1) {
        [cell.receiveBtn setTitle:@"进行中" forState:0];
        cell.receiveBtn.backgroundColor = [UIColor colorWithHexString:@"0080FF"];
    }else if ([model.status integerValue] == 2) {
        [cell.receiveBtn setTitle:@"领取" forState:0];
        cell.receiveBtn.backgroundColor = [UIColor orangeColor];
    }else if ([model.status integerValue] == 3) {
        [cell.receiveBtn setTitle:@"已领取" forState:0];
        cell.receiveBtn.backgroundColor = [UIColor lightGrayColor];
    }else {
        [cell.receiveBtn setTitle:@"去完成" forState:0];
        cell.receiveBtn.backgroundColor = [UIColor colorWithHexString:@"008040"];
    }
    cell.receiveBtn.tag = indexPath.section*10+indexPath.row+100;
    [cell.receiveBtn addTapBlock:^(UIButton *btn) {
        if ([cell.receiveBtn.titleLabel.text isEqualToString:@"领取"]) {
            TaskClassifyModel *cm = arr[(btn.tag-100)/10];
            TaskModel *m = cm.task[(btn.tag-100)%10];
            UserModel *user = [[UserConfig shareInstace] getAllInformation];
            [NetRequestClass afn_requestURL:@"appTaskGeg" httpMethod:@"POST" params:@{@"tl_id":m.tl_id,@"award_type":m.award_type,@"award_worth":m.tl_award,@"ub_id":user.ub_id,@"task_id":m.task_id}.mutableCopy successBlock:^(id returnValue) {
                if ([returnValue[@"status"] integerValue] == 1) {
                    [SVProgressHUD showSuccessWithStatus:returnValue[@"info"]];
                    [arr removeAllObjects];
                    [self requestData];
                    UIView *view;
                    if (view == nil) {
                        view = [[UIView alloc] initWithFrame:self.view.bounds];
                        view.backgroundColor = [UIColor clearColor];
                        [self.view addSubview:view];
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                            [view removeFromSuperview];
                        }];
                        [view addGestureRecognizer:tap];
                        UIView *awardView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth-280)/2, (KScreenHeight-250)/2-50, 280, 250)];
                        awardView.backgroundColor = [UIColor whiteColor];
                        awardView.layer.cornerRadius = 5;
                        awardView.layer.masksToBounds = YES;
                        [view addSubview:awardView];
                        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 240, 180)];
                        imgV.contentMode = UIViewContentModeScaleAspectFit;
                        imgV.image = [UIImage imageNamed:@"huatong"];
                        [awardView addSubview:imgV];
                        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280-40, 70)];
                        text.numberOfLines = 0;
                        text.text = @"恭喜你，获得上位送出一个话筒！";
                        text.textAlignment = NSTextAlignmentCenter;
                        text.font = [UIFont systemFontOfSize:16];
                        [awardView addSubview:text];
                    }
                    
                }
                else {
                    [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
                }
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TaskClassifyModel *model = arr[section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 85, 30)];
    [btn setTitle:[NSString stringWithFormat:@" %@", model.title] forState:0];
    [btn setImage:[UIImage imageNamed:@"我的任务页面任务"] forState:0];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    btn.userInteractionEnabled = NO;
    CGSize maxSize=CGSizeMake(KScreenWidth-140, MAXFLOAT);//定义一个限制控件内显示文字区域
    CGSize trueSize=[[NSString stringWithFormat:@" %@", model.title] boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:
                                                                                                                                     [UIFont systemFontOfSize:15]} context:nil].size;//trueSize为控件实际的大小
    btn.width = trueSize.width+25;
    [view addSubview:btn];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btn.right, 10, 100, 30)];
    label.text = [NSString stringWithFormat:@"（共%d个）", model.task.count];
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor orangeColor];
    [view addSubview:label];
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
    [NetRequestClass afn_requestURL:@"appTask" httpMethod:@"GET" params:@{@"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            for (NSDictionary *dic in returnValue[@"data"][@"data"]) {
                TaskClassifyModel *model = [TaskClassifyModel mj_objectWithKeyValues:dic];
                NSMutableArray *taskArr = @[].mutableCopy;
                for (NSDictionary *dict in model.task) {
                    TaskModel *taskModel = [TaskModel mj_objectWithKeyValues:dict];
                    [taskArr addObject:taskModel];
                }
                model.task = taskArr;
                [arr addObject:model];
            }
            
            [self.tableView reloadData];
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
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
