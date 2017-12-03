//
//  TaskModel.h
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/2.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject
@property (nonatomic, strong) NSString *task_id;
@property (nonatomic, strong) NSString *tk_title;
@property (nonatomic, strong) NSString *tk_des;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *award_type;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *tl_id;
@property (nonatomic, strong) NSString *tl_award;
@property (nonatomic, strong) NSString *tl_plan;
@property (nonatomic, strong) NSString *plan;
@end
