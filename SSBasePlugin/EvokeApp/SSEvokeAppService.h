//
//  AMDSourceAppOpenService.h
//  AppMicroDistribution
//  进入App内 相应跳转处理
//  Created by SunSet on 15-11-17.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSModuleManager/SSModule.h>
#import "SSPluginActionModel.h"

@protocol SSEvokeConfig<NSObject>

@optional
// 唤起的url标识符
- (NSString *)evokeUrlScheme;

// 点击处理回调事件
// action {action_type:xxx, action_params:xxx}
- (void (^)(SSPluginActionModel *actionModel))handleAction;
@end


@interface SSEvokeAppService : NSObject<SSModule>

/**
 1, 目前支持url跳进App
 2, 第三方页面回调处理
 3, 支持uninval link 功能
 */

@property(nonatomic, weak) id<SSEvokeConfig> config;

@end





















