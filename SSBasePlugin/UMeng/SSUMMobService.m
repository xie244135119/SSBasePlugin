//
//  AMDUMMobService.m
//  AppMicroDistribution
//
//  Created by 马清霞 on 2017/7/7.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "SSUMMobService.h"
#import <UMMobClick/MobClick.h>

@implementation SSUMMobService


#pragma mark -  SSModuleProtrol
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    NSString *appKey = @"";
    NSString *appSecret = nil;
    NSString *channleid = nil;
#ifdef DEBUG
    // 默认输出日志
    [MobClick setLogEnabled:YES];
#else
    appKey = [self.mobConfig mobAppKey];
    if ([self.mobConfig respondsToSelector:@selector(mobAppSecret)]) {
        appSecret = [self.mobConfig mobAppSecret];
    }
    if ([self.mobConfig respondsToSelector:@selector(mobChannelId)]) {
        channleid = [self.mobConfig mobChannelId];
    }
#endif
    UMAnalyticsConfig *config = [UMAnalyticsConfig sharedInstance];
    config.appKey = appKey;
    config.secret = appSecret;
    config.channelId = channleid;
    [MobClick startWithConfigure:config];
    
    return YES;
}

+ (void)beginLogPageView:(NSString *)pageName
{
    [MobClick beginLogPageView:pageName];
}


+ (void)endLogPageView:(NSString *)pageName
{
    [MobClick endLogPageView:pageName];
}


@end









