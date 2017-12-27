//
//  RootWebViewController.m
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/18.
//  Copyright © 2017年 徐阳. All rights reserved.
//

#import "RootWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface RootWebViewController ()<WKNavigationDelegate,WKUIDelegate, WKScriptMessageHandler,WKUIDelegate>

@property (strong, nonatomic) UIProgressView *progressView;//这个是加载页面的进度条

@end

@implementation RootWebViewController

-(instancetype)initWithUrl:(NSString *)url orHtml:(NSString *)html{
    self = [super init];
    if (self) {
        self.url = url;
        self.html = html;
        _progressViewColor = [UIColor colorWithRed:119.0/255 green:228.0/255 blue:115.0/255 alpha:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initWKWebView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initProgressView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}
#pragma mark 初始化webview
-(void)initWKWebView
{
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];//先实例化配置类 以前UIWebView的属性有的放到了这里
    //注册供js调用的方法
    _userContentController =[[WKUserContentController alloc]init];

//    [userContentController addScriptMessageHandler:self name:@"showMobile"];
//    [userContentController addScriptMessageHandler:self name:@"showName"];
//    [userContentController addScriptMessageHandler:self name:@"showSendMsg"];
//    
    configuration.userContentController = _userContentController;
    configuration.preferences.javaScriptEnabled = YES;//打开js交互
    _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) configuration:configuration];
    [self.view addSubview:_wkwebView];
    _wkwebView.backgroundColor = [UIColor clearColor];
    _wkwebView.allowsBackForwardNavigationGestures =YES;//打开网页间的 滑动返回
    _wkwebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    if (kiOS9Later) {
        _wkwebView.allowsLinkPreview = YES;//允许预览链接
    }
    _wkwebView.UIDelegate = self;
    _wkwebView.navigationDelegate = self;
    [_wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//注册observer 拿到加载进度
    _wkwebView.UIDelegate = self;
    if (self.url != nil && [self.url length]>0) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [_wkwebView loadRequest:request];
    }else if (self.html != nil && [self.html length]>0) {
        [_wkwebView loadHTMLString:self.html baseURL:nil];
    }
     [self.wkwebView.configuration.userContentController addScriptMessageHandler:self name:@"PresentGiftClick"];
}

#pragma mark --这个就是设置的上面的那个加载的进度
-(void)initProgressView
{
    CGFloat progressBarHeight = 3.0f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    //        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight-0.5, navigaitonBarBounds.size.width, progressBarHeight);
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
    if (!_progressView || !_progressView.superview) {
        _progressView =[[UIProgressView alloc]initWithFrame:barFrame];
        _progressView.tintColor = [UIColor colorWithHexString:@"0485d1"];
        _progressView.trackTintColor = [UIColor clearColor];
        
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
}
//检测进度条，显示完成之后，进度条就隐藏了
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (object == self.wkwebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}


#pragma mark - ——————— WKNavigationDelegate ————————
// 页面开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
// 当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.title = webView.title;
    if ([self.title length]==0) {
        self.title = @"单页详情";
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
}

// 页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}

#pragma mark - update nav items

-(void)updateNavigationItems{
    if (self.wkwebView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        [self addNavigationItemWithTitles:@[@"返回",@"关闭"] isLeft:YES target:self action:@selector(leftBtnClick:) tags:@[@2000,@2001]];
        
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        //iOS8系统下发现的问题：在导航栏侧滑过程中，执行添加导航栏按钮操作，会出现按钮重复，导致导航栏一系列错乱问题
        //解决方案待尝试：每个vc显示时，遍历 self.navigationController.navigationBar.subviews 根据tag去重
        //现在先把iOS 9以下的不使用动态添加按钮 其实微信也是这样做的，即便返回到webview的第一页也保留了关闭按钮
        
        if (kiOS9Later) {
            [self addNavigationItemWithTitles:@[@"返回"] isLeft:YES target:self action:@selector(leftBtnClick:) tags:@[@2001]];
        }
    }
}

-(void)leftBtnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 2000:
            [self.wkwebView goBack];
            break;
        case 2001:
            [self backBtnClicked];
            break;
        default:
            break;
    }
}

-(void)reloadWebView{
    [self.wkwebView reload];
}
-(void)dealloc{
    [self clean];
}
#pragma mark ————— 清理 —————
-(void)clean{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
    self.wkwebView.UIDelegate = nil;
    self.wkwebView.navigationDelegate = nil;
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *parm = message.body;
    UserModel *user = [[UserConfig shareInstace] getAllInformation];
    if ([message.name isEqualToString:@"PresentGiftClick"]) {
        if ([parm[@"type"] isEqualToString:@"user"]) {
            [self.wkwebView evaluateJavaScript:[NSString stringWithFormat:@"calluser('{\"nickname\":\"%@\",\"headimgurl\":\"%@\",\"openid\":\"%@\",\"sex\":\"%@\",\"deviceid\":\"%@\",\"ub_id\":\"%@\"}')",  user.nickname,user.headpic,user.wx_openid,user.sex,[[NSUUID UUID] UUIDString],user.ub_id] completionHandler:^(id _Nullable item, NSError * _Nullable error) {
                //window.webkit.messageHandlers.calluser.postMessage({type : 'user'})
            }];
        }else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"点击了赠送，app下一步操作" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                //NSString *str = @"{name:\"冷婷\", amount:\"9999999\", phone:\"18600012345\"}";
                [self.wkwebView evaluateJavaScript:[NSString stringWithFormat:@"callJS('%@')", @"success"] completionHandler:^(id _Nullable item, NSError * _Nullable error) {
                    
                }];
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
   
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler();//此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
        
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
