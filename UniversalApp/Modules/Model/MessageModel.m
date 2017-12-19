//
//  MessageModel.m
//  UniversalApp
//
//  Created by 冷婷 on 2017/12/3.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel
-(id)initWithCoder: (NSCoder*)coder
{
    if(self= [super init])
    {
        self.msg_id=[coder decodeObjectForKey:@"msg_id"];
        self.isread=[coder decodeObjectForKey:@"isread"];
        self.readtime=[coder decodeObjectForKey:@"readtime"];
        self.istop=[coder decodeObjectForKey:@"istop"];
        self.mc_id=[coder decodeObjectForKey:@"mc_id"];
        self.icon=[coder decodeObjectForKey:@"icon"];
        self.url=[coder decodeObjectForKey:@"url"];
        self.title=[coder decodeObjectForKey:@"title"];
        self.suetime=[coder decodeObjectForKey:@"suetime"];
        self.ishref=[coder decodeObjectForKey:@"ishref"];
        self.module=[coder decodeObjectForKey:@"module"];
        self.module_id=[coder decodeObjectForKey:@"module_id"];
        self.time_switch = [coder decodeObjectForKey:@"time_switch"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.msg_id forKey:@"msg_id"];
   
    [coder encodeObject:self.isread forKey:@"isread"];
    [coder encodeObject:self.readtime forKey:@"readtime"];
    [coder encodeObject:self.istop forKey:@"istop"];
    [coder encodeObject:self.mc_id forKey:@"mc_id"];
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.suetime forKey:@"suetime"];
    [coder encodeObject:self.ishref forKey:@"ishref"];
    [coder encodeObject:self.module forKey:@"module"];
    [coder encodeObject:self.module_id forKey:@"module_id"];
    [coder encodeObject:self.time_switch forKey:@"time_switch"];
}
@end
