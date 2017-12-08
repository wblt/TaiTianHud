//
//  MoreStarCollectionCell.m
//  UniversalApp
//
//  Created by 何建波 on 2017/12/8.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MoreStarCollectionCell.h"

@implementation MoreStarCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.contentView.layer.borderWidth = 1;
    self.img.layer.cornerRadius = 5;
    self.img.layer.masksToBounds = YES;
}

@end
