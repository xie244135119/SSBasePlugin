//
//  SSPgyerPlugin.h
//  AppMicroDistribution
//  蒲公英插件使用--内测使用
//  Created by SunSet on 2017/7/13.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <SSModuleManager/SSModuleManager.h>

@interface SSPgyerPlugin : NSObject
//<SSModuleProtrol>



#pragma mark -

/**
 配置线上和sandbox测试账号 <默认为sunset的蒲公英权限>
 dev 账号不配置的话，默认取线上账号
 
 @param appKey 蒲公英appKey
 @param uKey 蒲公英uKey
 */
+ (void)configPgyerApiKey:(NSString *)appKey
                     uKey:(NSString *)uKey;
+ (void)configPgyerDevApiKey:(NSString *)appKey
                     devUKey:(NSString *)uKey;




#pragma mark -

/**
 前者和后者版本号比较

 @param version 版本号
 @param senderVersion 对比的版本号
 @return NSComparisonResult
 */
- (NSComparisonResult)compareVersion:(NSString *)version
                       senderVersion:(NSString *)senderVersion;

@end





