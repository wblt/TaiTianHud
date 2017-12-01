//
//  EditPasswordViewController.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/29.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "InformationEditCell.h"
@interface EditPasswordViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *arr;
}

@end

@implementation EditPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.rowHeight = 55;
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    arr = @[@"旧密码",@"新密码",@"新密码"];
    [self.tableView registerNib:[UINib nibWithNibName:@"InformationEditCell" bundle:nil] forCellReuseIdentifier:@"InformationEditCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InformationEditCell *cell = (InformationEditCell *)[tableView dequeueReusableCellWithIdentifier:@"InformationEditCell" forIndexPath:indexPath];
    cell.nickName.text = [NSString stringWithFormat:@"%@：", arr[indexPath.row]];
    cell.textField.placeholder = [NSString stringWithFormat:@"输入%@", arr[indexPath.row]];
    cell.textField.textAlignment = NSTextAlignmentLeft;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80)];
    view.backgroundColor = [UIColor clearColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 25, KScreenWidth-40, 55)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"确 定" forState:0];
    btn.layer.cornerRadius = 3;
    btn.layer.masksToBounds = YES;
    [btn addTapBlock:^(UIButton *btn) {
        NSMutableArray *textArr = [NSMutableArray array];
        for (int i = 0; i<3; i++) {
            InformationEditCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [textArr addObject:cell.textField.text];
        }
        [NetRequestClass afn_requestURL:@"appTelSbt" httpMethod:@"GET" params:@{@"nickname":textArr[0],@"realname":textArr[1],@"idcard":textArr[2]}.mutableCopy successBlock:^(id returnValue) {
            if ([returnValue[@"status"] integerValue] == 1) {
                
                
            }
            else {
                [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }];
    [view addSubview:btn];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
