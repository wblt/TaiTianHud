//
//  LTAlertView.m
//  UniversalApp
//
//  Created by 何建波 on 2017/11/29.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "LTAlertView.h"

@implementation LTAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.text = self.title;
}

- (IBAction)toCentain:(UIButton *)sender {
    if (self.centainBlock) {
        self.centainBlock(self);
    }
}

- (IBAction)toCancle:(UIButton *)sender {
    [self removeFromSuperview];
}

//- (IBAction)cancleTap:(id)sender {
//    [self removeFromSuperview];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
