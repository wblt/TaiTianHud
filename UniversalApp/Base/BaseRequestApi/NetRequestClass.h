//
//  NetRequestClass.h
//  MVVMTest
//
//  Created by 李泽鲁 on 15/1/6.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import <Foundation/Foundation.h>

//定义返回请求数据的block类型
typedef void (^ReturnValueBlock) (id returnValue);
typedef void (^ErrorCodeBlock) (id errorCode);
typedef void(^FailureBlock)(NSError *error);
typedef void (^NetWorkBlock)(BOOL netConnetState);
typedef void(^ProgressBlock)(CGFloat progress);

#define kGET @"GET"

#define TIMEOUT 30

@interface NetRequestClass : NSObject

#pragma 监测网络的可链接性
+(BOOL)netWorkReachabilityWithURLString:(NSString *) strUrl;

// 原生请求
+ (void)native_requestURL:(NSString *)urlString httpMethod:(NSString *)method
            params:(NSMutableDictionary *)parmas
      successBlock:(ReturnValueBlock)successBlock
      failureBlock:(FailureBlock)failureBlock;


// afn 请求
+ (void)afn_requestURL:(NSString *)urlString httpMethod:(NSString *)method
            params:(NSMutableDictionary *)parmas
      successBlock:(ReturnValueBlock)successBlock
      failureBlock:(FailureBlock)failureBlock;

/**
 *  文件下载
 *
 *  @param urlString    下载地址
 *  @param desPath      下载文件存放地址
 *  @param successBlock 成功回调
 *  @param failureBlock 失败回调
 */
+ (NSURLSessionDownloadTask *)downloadURL:(NSString *)urlString desPath:(NSString *)desPath fileName:(NSString *)fileName  progressBlock:(ProgressBlock)progressBlock successBlock:(ReturnValueBlock)successBlock failureBlock:(FailureBlock)failureBlock;

/**
 *  上传文件
 *
 *  @param urlstring    接口地址
 *  @param method       上传方式
 *  @param parmas       上传参数
 *  @param files        文件信息
 *  @param fileName     文件名
 *  @param mimeType     类型名
 *  @param successBlock 成功回调
 *  @param failureBlock 失败回调
 */
+ (void)requestURL:(NSString *)urlstring
        httpMethod:(NSString *)method
            params:(NSMutableDictionary *)parmas
              file:(NSDictionary *)files
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
      successBlock:(ReturnValueBlock)successBlock
      failureBlock:(FailureBlock)failureBlock;

@end
