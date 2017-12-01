//
//  LTAlertView.h
//  UniversalApp
//
//  Created by 何建波 on 2017/11/29.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CentainBlock)(UIView *view);
typedef void(^CancleBlock)(UIView *view);
@interface LTAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,copy) CentainBlock centainBlock;
@property (nonatomic,copy) CancleBlock cancleBlock;
@end
