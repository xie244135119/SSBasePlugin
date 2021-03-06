//
//  SSApnsPushService.m
//  SSBasePlugin
//
//  Created by SunSet on 15-5-19.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//


//static NSString * const AMDPushTag = @"ylwfxpush_ios";


#import "SSApnsPushService.h"
#import <JPush/JPUSHService.h>
#import <UserNotifications/UserNotifications.h>

@interface SSApnsPushService() <JPUSHRegisterDelegate, SSPushConfig>
{
    NSDictionary *_launchOptions;           //启动时携带的跳转参数
    BOOL _onLoadSuccess;                        //已经启动渲染成功
}
@end

@implementation SSApnsPushService


- (void)dealloc
{
    _launchOptions = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - SSModuleProtrol
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    // 记录启动参数 等进入首页的时候渲染
    _launchOptions = launchOptions;
    
    // 默认配置
    [self setupWithOption:launchOptions];
    
    return YES;
}


// 注册Token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 上传Token
    [JPUSHService registerDeviceToken:deviceToken];
}


// 模块登录成功之后处理
- (void)login
{
    [self registerWithAlias];
}

// 登录渲染完成
- (void)onloadSuccess
{
    _onLoadSuccess = YES;
    // 是否有推送信息
    if (_launchOptions) {
        [self LaunchingWithOptions:_launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        _launchOptions = nil;
    }
}

- (void)logout
{
    _onLoadSuccess = NO;
    _launchOptions = nil;
}

// 收到远程通知的时候
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self _handleReceiveRemoteNotification:userInfo];
}


#pragma mark - private api
- (void)setupWithOption:(NSDictionary *)launchingOption  // 初始化
{
    // 注册通知
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    // 目前无用
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveNotAPSMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    NSString *appKey = @"";
    if ([self respondsToSelector:@selector(pushAppKey)]) {
        appKey = [self pushAppKey];
    }
    BOOL isProduction = YES;
#ifdef DEBUG
    if ([self respondsToSelector:@selector(pushAppKey_Dev)]) {
        appKey = [self pushAppKey_Dev];
    }
    isProduction = NO;
#endif
    
    // 注册SDK
    [JPUSHService setupWithOption:launchingOption appKey:appKey channel:nil apsForProduction:isProduction];

    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.0) {
        //10.0 之后采用的
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc]init];
        entity.types = JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionAlert;
        // 10.0
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else {
        // 设置注册方式
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert) categories:nil];
    }
}


// 别名注册
- (void)registerWithAlias
{
    NSString *alias = @"";
    NSSet *tags = nil;
#if DEBUG
    if ([self respondsToSelector:@selector(pushAlias_Dev)]) {
        alias = [self pushAlias_Dev];
    }
    if ([self respondsToSelector:@selector(pushTags_Dev)]) {
        tags = [self pushTags_Dev];
    }
#else
    if ([self respondsToSelector:@selector(pushAlias)]) {
        alias = [self pushAlias];
    }
    if ([self respondsToSelector:@selector(pushTags)]) {
        tags = [self pushTags];
    }
    // 关闭日志模式
    [JPUSHService setLogOFF];
#endif
    
    // 设置Tag
    [JPUSHService setTags:tags completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        NSLog(@" JPush Tag注册结果 %@%@ ",@(iResCode),iTags);
    } seq:0];
    
    // 设置别名
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        NSLog(@" JPush Alias注册结果 %@%@ ",@(iResCode),iAlias);
    } seq:0];
}


//收到非APS消息的时候(只有在前端运行的时候才会收到自定义消息)
- (void)networkDidReceiveNotAPSMessage:(NSNotification *)notification
{
    NSLog(@" networkDidReceiveNotAPSMessage %@ ",notification);
    //    NSDictionary * userInfo = [notification userInfo];
    //    NSString *content = [userInfo valueForKey:@"content"];
    //    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    //    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
}


// App内收到apns推送的信息
- (BOOL)didReceiveAPSMessage:(NSDictionary *)userInfo
{
    if (!_onLoadSuccess) {
        // 尚未登录
        return NO;
    }
    
    if (userInfo[@"action_type"] == nil || userInfo[@"action_params"] == nil) {
        // 只需要展示
        return NO;
    }
    
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:{      //激活状态下
            // 需要提示用户是否需要查看
            NSString *title = userInfo[@"aps"][@"alert"];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"推送消息" message:title preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil];
            __weak typeof(self) weakself = self;
            UIAlertAction *read = [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakself LaunchingWithOptions:userInfo];
            }];
            [alertController addAction:read];
            [alertController addAction:cancel];
            
            UIViewController *controller = [[[UIApplication sharedApplication].delegate window] rootViewController];
            [controller presentViewController:alertController animated:YES completion:nil];
            return YES;
        }
            break;
        case UIApplicationStateInactive:   {    //待激活状态
            // 跳转
                [self LaunchingWithOptions:userInfo];
            return YES;
        }
            break;
        default: {
            return NO;
        }
            break;
    }
}


//#pragma mark - 通过点击广告App内做相应的跳转
// 存储用户附带的消息进行跳转
// 参数：额外附带的参数
- (void)LaunchingWithOptions:(NSDictionary *)Options
{
    NSString *action_type = Options[@"action_type"];
    NSString *action_param = Options[@"action_params"];
    if (action_param == nil || action_type == nil) {
        // 不存在额外跳转的字段
        return;
    }
    
    // 等登录成功跳转相应的页面
    if ([self respondsToSelector:@selector(handleAction)]) {
        void (^action)(SSPluginActionModel *actionModel) = [self handleAction];
        if (action) {
            dispatch_time_t aftertime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)0.1);
            dispatch_after(aftertime, dispatch_get_main_queue(), ^{
                SSPluginActionModel *model = [[SSPluginActionModel alloc]initWithActionType:action_type actionParams:action_param actionUrl:nil];
                action(model);
            });
        }
    }
}

// 处理收到的推送消息
- (BOOL)_handleReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 处理APNS消息
    // 极光推送
    if ([userInfo.allKeys containsObject:@"_j_msgid"]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        //处理推送--apns消息
        return [self didReceiveAPSMessage:userInfo];
    }
    return NO;
}


#pragma mark - JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    BOOL handler = NO;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // App内跳转
       handler = [self _handleReceiveRemoteNotification:userInfo];
    }
    completionHandler(!handler?UNNotificationPresentationOptionAlert:UNNotificationPresentationOptionSound); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self _handleReceiveRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}




@end




