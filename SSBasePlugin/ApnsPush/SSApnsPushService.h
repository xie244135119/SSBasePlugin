//
//  AMDPushService.h
//  AppMicroDistribution
//  极光推送服务<目前集成极光推送服务>
//  Created by SunSet on 15-5-19.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSModuleManager/SSModule.h>


@protocol SSPushConfig<NSObject>
// AppKey
- (NSString *)pushAppKey;

@optional
// 测试AppKey
- (NSString *)pushAppKey_Dev;
// 注册Tag
- (NSSet *)pushTags;
- (NSSet *)pushTags_Dev;
// 别名
- (NSString *)pushAlias;
- (NSString *)pushAlias_Dev;

// 点击处理回调事件
// action {action_type:xxx, action_params:xxx}
- (void (^)(NSDictionary *action))handleAction;

@end


@interface SSApnsPushService : NSObject<SSModule>

// 配置信息
@property(nonatomic, weak) id<SSPushConfig> pushConfig;


@end









