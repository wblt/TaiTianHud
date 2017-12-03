//
//  MessageModel.h
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/3.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject
@property (nonatomic, strong) NSString *msg_id;
@property (nonatomic, strong) NSString *isread;
@property (nonatomic, strong) NSString *readtime;
@property (nonatomic, strong) NSString *istop;
@property (nonatomic, strong) NSString *mc_id;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;

@end
