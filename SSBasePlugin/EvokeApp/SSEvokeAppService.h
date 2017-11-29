//
//  SSEvokeAppService.h
//  SSBasePlugin
//  进入App内 相应跳转处理
//  Created by SunSet on 15-11-17.
//  Copyright (c) 2015年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSModuleManager/SSModule.h>
#import "SSPluginActionModel.h"

/*
 集成指南
 1, 通过类别 或 分类 实现SSEvokeConfig协议即可
 */

@protocol SSEvokeConfig<NSObject>

@optional
// 唤起的url标识符
- (NSString *)evokeUrlScheme;

// 点击处理回调事件
- (void (^)(SSPluginActionModel *actionModel))handleAction;
@end


@interface SSEvokeAppService : NSObject<SSModule>

/**
 1, 目前支持url跳进App
 2, 第三方页面回调处理
 3, 支持uninval link 功能
 */

@end





















