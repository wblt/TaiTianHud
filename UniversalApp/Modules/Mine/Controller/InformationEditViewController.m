//
//  InformationEditViewController.m
//  TaitianHud
//
//  Created by 冷婷 on 2017/10/21.
//  Copyright © 2017年 wb. All rights reserved.
//

#import "InformationEditViewController.h"
#import "InformationEditCell.h"
#import "XZPickView.h"
#import "EmitterViewController.h"
@interface InformationEditViewController () <UITableViewDataSource, UITableViewDelegate,XZPickViewDelegate,XZPickViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSArray *arr;
    UserModel *model;
    UIImagePickerController *imagePicker;
    UIImage *originalImage;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewInfoemation;
@property (nonatomic,strong) XZPickView *emitterPickView;
@property (nonatomic,copy) NSArray * emitterArray;
@end

@implementation InformationEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完善个人信息";
    self.tableViewInfoemation.dataSource = self;
    self.tableViewInfoemation.delegate = self;
    [self.tableViewInfoemation registerNib:[UINib nibWithNibName:@"InformationEditCell" bundle:nil] forCellReuseIdentifier:@"InformationEditCell"];
    self.tableViewInfoemation.rowHeight = 55;
    arr = @[@"昵称",@"真实姓名",@"身份证号码",@"性别",@"邮箱",@"详细地址",@"个性签名"];
    model = [[UserConfig shareInstace] getAllInformation];
    [self requestData];
    
    self.emitterArray = @[@[@"彩带",@"下雪",@"下雨",@"烟花"],@[@"彩带",@"下雪",@"下雨",@"烟花"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //默认导航栏样式：黑字
    self.StatusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:18]}];
}

- (void)requestData
{
    NSMutableDictionary *dic = @{@"ub_id":model.ub_id}.mutableCopy;
    [NetRequestClass afn_requestURL:@"appInfo" httpMethod:@"GET" params:dic successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            
            model = [UserModel mj_objectWithKeyValues:returnValue[@"data"]];
            [self.tableViewInfoemation reloadData];
            
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InformationEditCell *cell = (InformationEditCell *)[tableView dequeueReusableCellWithIdentifier:@"InformationEditCell" forIndexPath:indexPath];
    if (indexPath.row == 3) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textField.hidden = YES;
        cell.sexLabel.hidden = NO;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.sexLabel.hidden = YES;
        cell.textField.hidden = NO;
    }
    cell.nickName.text = [NSString stringWithFormat:@"%@：", arr[indexPath.row]];
    cell.textField.placeholder = [NSString stringWithFormat:@"输入%@", arr[indexPath.row]];
    if (indexPath.row == 0) {
        cell.textField.text = model.nickname;
    }else if (indexPath.row == 1) {
        cell.textField.text = model.realname;
    }else if (indexPath.row == 2) {
        cell.textField.text = model.idcard;
    }else if (indexPath.row == 3) {
        cell.sexLabel.text = [model.sex integerValue] == 1?@"男":@"女";
    }else if (indexPath.row == 4) {
        cell.textField.text = model.email;
    }else if (indexPath.row == 6) {
        cell.textField.text = model.stylesig;
    }else if (indexPath.row == 5) {
        cell.textField.text = model.address;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 3) {
        [self ActionSheetWithTitle:@"性别" message:@"选择性别" destructive:nil destructiveAction:nil andOthers:@[@"取消",@"男",@"女"] animated:YES action:^(NSInteger index) {
            if (index != 0) {
                model.sex = @(index);
                [self.tableViewInfoemation reloadData];
            }
        }];
    }
//    else {
//        [self.emitterPickView reloadData];
//        //[self.userNumPickView selectRow:0 inComponent:0 animated:NO];
//        [kAppWindow addSubview:self.emitterPickView];
//        [self.emitterPickView show];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[[NSBundle mainBundle] loadNibNamed:@"InformationHeadView" owner:self options:nil] lastObject];
    UIImageView *img = (UIImageView *)[v viewWithTag:201];
    [img sd_setImageWithURL:[NSURL URLWithString:model.headpic] placeholderImage:[UIImage imageNamed:@"friend_default"]];
    UIButton *changeHead = (UIButton *)[v viewWithTag:202];
    [changeHead addTapBlock:^(UIButton *btn) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机选择照片", @"拍照片", nil];
        [actionSheet showInView:self.view];
    }];
    return v;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 25, kScreenWidth, 55)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"修改资料" forState:0];
    [btn setTitleColor:[UIColor whiteColor] forState:0];
    [btn addTarget:self action:@selector(toCommit) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:btn];
    return v;
}

- (void)toCommit
{
    NSMutableArray *textArr = [NSMutableArray array];
    for (int i = 0; i<7; i++) {
        InformationEditCell *cell = [self.tableViewInfoemation cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [textArr addObject:cell.textField.text];
    }
    [NetRequestClass afn_requestURL:@"appInfoSbt" httpMethod:@"POST" params:@{@"nickname":textArr[0],@"ub_id":model.ub_id,@"realname":textArr[1],@"idcard":textArr[2],@"sex":model.sex,@"email":textArr[4],@"stylesig":textArr[6],@"address":textArr[5],@"column":@[@"湖南",@"长沙"]}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark -  XZPickView 代理
//列数
-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return self.emitterArray.count;
}

//行数
-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *a = self.emitterArray[component];
    return a.count;
}

//标题
-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *a = self.emitterArray[component];
    return a[row];
}
//确认按钮点击
-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{
    //    NSInteger left = [pickerView selectedRowInComponent:0];
    //    EmitterViewController *emitterVC = [[EmitterViewController alloc] init];
    //    emitterVC.animation_type = left;
    //    [self.navigationController pushViewController:emitterVC animated:YES];
    
}

//滑动选中
-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(XZPickView *)emitterPickView{
    if(!_emitterPickView){
        _emitterPickView = [[XZPickView alloc]initWithFrame:kScreen_Bounds title:@"请选择"];
        _emitterPickView.delegate = self;
        _emitterPickView.dataSource = self;
    }
    return _emitterPickView;
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if (buttonIndex == 0) {/**<相册库选取照片*/
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else if (buttonIndex == 1){/**<拍照选取照片*/
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                  message:@"设备不支持拍照功能"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [myAlertView show];
            return;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }else if (buttonIndex == 2){
        
        return ;
    }
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
//相册处理，获取图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {/**<选中照片回调*/
    
    originalImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
    }
    UIImageView *headImg = (UIImageView *)[self.view viewWithTag:201];
    headImg.image = originalImage;
    
    //    NSData *imgdata = UIImageJPEGRepresentation(originalImage, 0.8);
    //    [[NSUserDefaults standardUserDefaults] setObject: [[NSString alloc] initWithData:imgdata  encoding:NSUTF8StringEncoding] forKey:@"headImge"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self requestModifyHeadImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {/**<不选照片点击取消回调*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestModifyHeadImg
{
    UserModel *model = [[UserConfig shareInstace] getAllInformation];
    [NetRequestClass afn_requestURL:@"appHeadpicSbt" httpMethod:@"POST" params:@{@"img":[UIImagePNGRepresentation(originalImage) base64EncodedStringWithOptions: 0],@"ub_id":model.ub_id}.mutableCopy successBlock:^(id returnValue) {
        if ([returnValue[@"status"] integerValue] == 1) {
            UserModel *model = [[UserConfig shareInstace] getAllInformation];
            model.headpic = returnValue[@"data"];
            [[UserConfig shareInstace] setAllInformation:model];
            [self.tableViewInfoemation reloadData];
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
        }
        else {
            [SVProgressHUD showErrorWithStatus:returnValue[@"info"]];
        }
    } failureBlock:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"上传失败"];
    }];
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
