//
//  SSPgyerPlugin.h
//  AppMicroDistribution
//  蒲公英插件使用--内测使用
//  Created by SunSet on 2017/7/13.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SSModuleManager/SSModuleManager.h>

@interface SSPgyerPlugin : NSObject<SSModuleProtrol>



#pragma mark -

/**
 配置 <默认为sunset的蒲公英权限>

 @param appKey 蒲公英appKey
 @param uKey 蒲公英uKey
 */
+ (void)configPgyerAppKey:(NSString *)appKey
                     uKey:(NSString *)uKey;




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





