//
//  NetRequestClass.m
//  MVVMTest
//
//  Created by 李泽鲁 on 15/1/6.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import "NetRequestClass.h"


@implementation NetRequestClass

/**
 监测网络的可链接性

 @param strUrl URL地址
 @return 是否可达
 */
+(BOOL)netWorkReachabilityWithURLString:(NSString *) strUrl {
    __block BOOL netState = YES;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
                netState = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                netState = YES;
                break;
           
            default:
                break;
        }
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    return netState;
}


+ (void)native_requestURL:(NSString *)urlString httpMethod:(NSString *)method
            params:(NSMutableDictionary *)parmas
      successBlock:(ReturnValueBlock)successBlock
      failureBlock:(FailureBlock)failureBlock {
    // 1 拼接地址
    //utf8编码
    NSString *ut8Str = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *requestURL = [BaseUrl stringByAppendingString:ut8Str];
    
    NSURL *url = [NSURL URLWithString:requestURL];
    //2.创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.创建会话（这里使用了一个全局会话）
    NSURLSession *session = [NSURLSession sharedSession];
    //4.通过会话创建任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            
                                                        if (successBlock) {
                                                                successBlock(data);
                                                            }
                                                            
                                                            
                                                        });
                                                        
                                                    }else{
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            //上传失败
                                                            if (failureBlock) {
                                                                failureBlock(error);
                                                            }
                                                            
                                                        });
                                                    }
                                                }];
    //5.每一个任务默认都是挂起的，需要调用 resume 方法启动任务
    [dataTask resume];
    
}

+ (void)afn_requestURL:(NSString *)urlString httpMethod:(NSString *)method
            params:(NSMutableDictionary *)parmas
      successBlock:(ReturnValueBlock)successBlock
      failureBlock:(FailureBlock)failureBlock {
    
    // 1 拼接地址
    //utf8编码
    NSString *ut8Str = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestURL= [BaseUrl stringByAppendingString:ut8Str];
    // 3. 构造一个操作对象的管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];//响应
    // 这里要注意一下，不同的接口，我们在这里拼接一下可能会出错
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/png", nil];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    //请求
    if ([[method uppercaseString] isEqualToString:@"GET"]) {
        [manager GET:requestURL parameters:parmas progress:^(NSProgress * _Nonnull downloadProgress) {
            //请求进度
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //上传成功
            if (successBlock) {
                successBlock(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //上传失败
            if (failureBlock) {
                failureBlock(error);
            }
        }];
        
    }else if ([[method uppercaseString] isEqualToString:@"POST"]) {
        
        [manager POST:requestURL parameters:parmas progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock) {
                successBlock(responseObject);
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //上传失败
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    }
}

/**
 *  文件下载
 *
 *  @param urlString    下载地址
 *  @param desPath      下载文件存放地址
 *  @param successBlock 成功回调
 *  @param failureBlock 失败回调
 */
+ (NSURLSessionDownloadTask *)downloadURL:(NSString *)urlString desPath:(NSString *)desPath fileName:(NSString *)fileName progressBlock:(ProgressBlock)progressBlock successBlock:(ReturnValueBlock)successBlock
                             failureBlock:(FailureBlock)failureBlock {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
#if 1
    NSString *downLoadUrl = [BaseUrl stringByAppendingString:urlString];
#else
    NSString *ss = @"http://dlqncdn.miaopai.com/stream/qCC408GAsmPC~CIc-5G8iQ__.mp4";
#endif
    
    //    NSString *urlS = [downLoadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:downLoadUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        CGFloat progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (progressBlock) {
                progressBlock(progress);
            }
        });
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // 指定下载文件保存的路径
        NSString * suggestedFilename = response.suggestedFilename;
        NSString *downloadPath = [NSString stringWithFormat:@"%@/%@",[self createFileDirectory],suggestedFilename];
        NSURL *fileURL = [NSURL fileURLWithPath:downloadPath];
        return fileURL;
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error == nil) {
            //下载成功
            if (successBlock) {
                successBlock(filePath);
            }
        }
        else {
            //下载失败
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
    [task resume];
    return task;
}

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
      failureBlock:(FailureBlock)failureBlock
{
    
    // 1 拼接地址
    NSString *requestURL = [BaseUrl stringByAppendingString:urlstring];
    // 3. 构造一个操作对象的管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    // 这里要注意一下，不同的接口，我们在这里拼接一下可能会出错
    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = TIMEOUT;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //请求
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        if (files != nil) {
            [manager POST:requestURL parameters:parmas constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                for (id key in files) {
                    id value = files[key];
                    [formData appendPartWithFileData:value
                                                name:key
                                            fileName:@"jpg"
                                            mimeType:@"application/octet-stream"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                //进度监听
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //成功
                if (successBlock) {
                    successBlock(responseObject);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //失败
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
            
        }
        
    }
}

/**
 @brief 根据文件路径来创建文件夹
 @return 是否创建成功
 */
+ (NSString *)createFileDirectory
{
    NSString *path =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"downloadFileDirectory"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
