//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
typedef void(^PayResultBlock)(NSString *result);
@interface WXApiManager : NSObject<WXApiDelegate>
@property (nonatomic, strong) PayResultBlock payResultBlock;
+ (instancetype)sharedManager;

@end
