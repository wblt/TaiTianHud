//
//  MyTaskCell.h
//  UniversalApp
//
//  Created by 何建波 on 2017/11/30.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;
@property (weak, nonatomic) IBOutlet UIButton *receiveBtn;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@end
