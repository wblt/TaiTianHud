//
//  HomeCompanyTableCell.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "HomeCompanyTableCell.h"

@implementation HomeCompanyTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.type.layer.borderColor = [UIColor whiteColor].CGColor;
    self.type.layer.borderWidth = 0.5;
    self.type.layer.cornerRadius = 2;
    self.type.layer.masksToBounds = YES;
    self.scrollImg.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
