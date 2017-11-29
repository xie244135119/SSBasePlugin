//
//  SSPgyerPlugin.h
//  SSBasePlugin
//  蒲公英插件使用--内测使用
//  Created by SunSet on 2017/7/13.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SSModuleManager/SSModule.h>

@interface SSPgyerPlugin : NSObject<SSModule>



#pragma mark - config

/**
 配置线上和sandbox测试账号 <默认为sunset的蒲公英权限>
 dev 账号不配置的话，默认取线上账号
 
 @param appKey 蒲公英appKey
 */
+ (void)configPgyerApiKey:(NSString *)appKey;
+ (void)configPgyerDevApiKey:(NSString *)appKey;




#pragma mark - public api

/**
 启动插件
 */
- (void)start;


/**
 前者和后者版本号比较

 @param version 版本号
 @param senderVersion 对比的版本号
 @return NSComparisonResult
 */
+ (NSComparisonResult)compareVersion:(NSString *)version
                       senderVersion:(NSString *)senderVersion;

@end



/**
 method
 1, 作为子模块集成进去
 [[SSModuleCenter defaultCenter] addModuleClass:NSClassFromString(@"SSPgyerPlugin")];
 2, 直接调用
    SSPgyerPlugin *plugin = [SSPgyerPlugin alloc] init];
    [plugin start];
 **/


/*
 1, 蒲公英api升级apv1到apv2
 2,
 */









