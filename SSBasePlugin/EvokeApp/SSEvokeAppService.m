//
//  AMDSourceAppOpenService.m
//  AppMicroDistribution
//
//  Created by SunSet on 15-11-17.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//

#import "SSEvokeAppService.h"

@interface SSEvokeAppService()<SSModule>
{
    NSURL *_universalLinkUrl;                       //配置通用链接地址
    NSURL *_applicationOpenUrl;                     //启动打开的页面
    
    BOOL _onLoadSuccess;                            //已经加载成功
    
}
@end

@implementation SSEvokeAppService


- (void)dealloc
{
    _applicationOpenUrl = nil;
    _universalLinkUrl = nil;
}


#pragma mark - SSModule
// 打开外部链接 <仅处理来自平台内部的链接>
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([self.config respondsToSelector:@selector(evokeUrlScheme)]) {
        // 来自我们自己平台的调用
        if ([url.scheme isEqualToString:self.config.evokeUrlScheme] ) {
            
            [self application:application openURL:url];
            return YES;
        }
    }
    return NO;
}


// 登录渲染完成
- (void)onloadSuccess
{
    _onLoadSuccess = YES;

    //  唤起 Universal link功能
    if (_universalLinkUrl) {
        [self handleOpenWithUrl:_universalLinkUrl];
        _universalLinkUrl = nil;
    }
    
    // 如果通过第三方Url跳转过来
    if (_applicationOpenUrl) {
        [self handleOpenWithUrl:_applicationOpenUrl];
        _applicationOpenUrl = nil;
    }
}


// 退出程序的时候
- (void)logout
{
    _onLoadSuccess = NO;
}


// associated domain跳转
-(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        // 不属于浏览器打开 不支持
        return YES;
    }
    
    // 在已经进入App主页的前提下，可以直接跳转
    if (_onLoadSuccess) {
        // 直接操作进入App
        [self handleOpenWithUrl:userActivity.webpageURL];
        return YES;
    }
    
    // 存储
    _universalLinkUrl = userActivity.webpageURL;
    return NO;
}



#pragma mark - private api
// 打开链接
- (void)application:(UIApplication *)application
            openURL:(NSURL *)url
{
    // 已经登录  直接跳转
    if (_onLoadSuccess) {
        [self handleOpenWithUrl:url];
        return;
    }
    
    // 刚打开App 需要等到进入到首页
    _applicationOpenUrl = url;
}

// 跳转页面处理
- (void)handleOpenWithUrl:(NSURL *)url
{
    if (url == nil) return;

    // 等登录成功跳转相应的页面
    if ([self.config respondsToSelector:@selector(handleAction)]) {
        void (^action)(SSPluginActionModel *actionModel) = [self.config handleAction];
        if (action) {
            dispatch_time_t aftertime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)0.2);
            dispatch_after(aftertime, dispatch_get_main_queue(), ^{
                SSPluginActionModel *model = [[SSPluginActionModel alloc]initWithActionType:nil actionParams:nil actionUrl:url.copy];
                action(model);
            });
        }
    }
}



@end










