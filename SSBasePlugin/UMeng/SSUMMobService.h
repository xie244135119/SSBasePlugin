//
//  SSUMMobService.h
//  
//  友盟统计模块
//  Created by 马清霞 on 2017/7/7.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SSModuleManager/SSModule.h>

/*
 集成指南
 1, 通过类别 或 分类 实现SSMobConfig协议即可
 */


// 默认为当前类自身实现此协议
@protocol SSMobConfig<NSObject>
// AppKey
- (NSString *)mobAppKey;

@optional
// AppSecret
- (NSString *)mobAppSecret;
// channleid 默认为Appstore
- (NSString *)mobChannelId;
@end


@interface SSUMMobService : NSObject<SSModule>


#pragma mark - 目前 V1.0 仅支持统计页面
// 统计页面时长
+ (void)beginLogPageView:(NSString *)pageName;
//
+ (void)endLogPageView:(NSString *)pageName;

@end








