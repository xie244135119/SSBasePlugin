//
//  SSPluginActionModel.h
//  SSBasePlugin
//
//  Created by SunSet on 2017/11/28.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSPluginActionModel : NSObject<NSCoding, NSCopying>


// 前两者主要适用于相应主体项目所支持的一套跳转体系
@property(nonatomic, copy) NSString *action_type;
@property(nonatomic, copy) NSString *action_params;

// 当前字段主要支持于通过URL跳转App的选项，方便本地进行解析处理
@property(nonatomic, strong) NSURL *action_url;


- (id)initWithActionType:(NSString *)actionType
            actionParams:(NSString *)actionParams
               actionUrl:(NSURL *)actionUrl;



@end
