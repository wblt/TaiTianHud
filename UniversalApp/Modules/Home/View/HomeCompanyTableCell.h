//
//  HomeCompanyTableCell.h
//  UniversalApp
//
//  Created by 何建波 on 2017/11/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
@interface HomeCompanyTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet SDCycleScrollView *scrollImg;

@property (weak, nonatomic) IBOutlet UIButton *time;
@property (weak, nonatomic) IBOutlet UIButton *address;
@property (weak, nonatomic) IBOutlet UIButton *personNum;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *type;

@end
