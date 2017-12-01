//
//  UserModel.h
//  TaTaTa
//
//  Created by mac on 15/9/21.
//  Copyright (c) 2015年 wb. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserModel : NSObject

@property (nonatomic,copy) NSString *userPhoneNum;

@property (nonatomic,copy) NSString *nickname;

@property (nonatomic,copy) NSString *userPassword;

@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,copy) NSString *h5_url;
@property (nonatomic,copy) NSString *headpic;
@property (nonatomic,copy) NSString *idcard;
@property (nonatomic,copy) NSNumber *isbindwx;
@property (nonatomic,copy) NSNumber *isvst;
@property (nonatomic,copy) NSString *realname;
@property (nonatomic,copy) NSNumber *sex;
@property (nonatomic,copy) NSString *stylesig;
@property (nonatomic,copy) NSNumber *totaljifen;
@property (nonatomic,copy) NSString *ua_id;
@property (nonatomic,copy) NSString *ub_id;
@property (nonatomic,copy) NSString *wx_openid;
@property (nonatomic,copy) NSString *wb_openid;
@property (nonatomic,copy) NSString *qq_openid;
@property (nonatomic,copy) NSString *source;
@property (nonatomic,copy) NSNumber *prise;
@property (nonatomic,copy) NSString *adddate;
@property (nonatomic,copy) NSNumber *addtime;
@property (nonatomic,copy) NSNumber *isuser;
@property (nonatomic,copy) NSNumber *isdel;
@property (nonatomic,copy) NSDictionary *isopen;

@end
