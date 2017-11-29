//  SSPushConfig.h
//  SSBasePlugin
//
//  极光推送服务<目前集成极光推送服务>
//  Created by SunSet on 15-5-19.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSModuleManager/SSModule.h>
#import "SSPluginActionModel.h"


/*
 集成指南
 1, 通过类别 或 分类 实现SSPushConfig协议即可
 */

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
- (void (^)(SSPluginActionModel *actionModel))handleAction;

@end


@interface SSApnsPushService : NSObject<SSModule>

// 配置信息
@property(nonatomic, weak) id<SSPushConfig> pushConfig;


@end









