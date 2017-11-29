//
//  SSUMMobService.m
//  SSBasePlugin
//
//  Created by SunSet on 2017/7/7.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "SSUMMobService.h"
#import <UMMobClick/MobClick.h>

@interface SSUMMobService()<SSMobConfig>

@end

@implementation SSUMMobService


#pragma mark -  SSModuleProtrol
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    NSString *appKey = [self mobAppKey];
    NSString *appSecret = nil;
    NSString *channleid = nil;
#ifdef DEBUG
    // 默认输出日志
    [MobClick setLogEnabled:YES];
#else
    appKey = [self mobAppKey];
    if ([self respondsToSelector:@selector(mobAppSecret)]) {
        appSecret = [self mobAppSecret];
    }
    if ([self respondsToSelector:@selector(mobChannelId)]) {
        channleid = [self mobChannelId];
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


#pragma mark - SSMobConfig
//
- (NSString *)mobAppKey
{
    return @"";
}

@end









