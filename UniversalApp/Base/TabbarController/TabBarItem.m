//
//  TabBarItem.m
//
//  Created by HCl on 15/4/12.
//  Copyright (c) 2015年 HCl. All rights reserved.
//

#import "TabBarItem.h"

@implementation TabBarItem

- (id)initWithFrame:(CGRect)frame
          imageName:(NSString *)name
              title:(NSString *)title {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //1.创建子视图
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-20)/2, 5, 20, 20)];
        /*
         设置内容模式:
         UIViewContentModeScaleToFill   默认： 拉伸填充
         UIViewContentModeScaleAspectFit   使用原图显示
         */
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = [UIImage imageNamed:name];
        [self addSubview:imgView];
        
        //2.创建标题视图
        
        CGFloat maxY = CGRectGetMaxY(imgView.frame);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, maxY, frame.size.width, 20)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.highlightedTextColor = [UIColor redColor];
        titleLabel.font = [UIFont systemFontOfSize:11.0];
        
        [self addSubview:titleLabel];
        
    }
    
    return self;
}
@end
