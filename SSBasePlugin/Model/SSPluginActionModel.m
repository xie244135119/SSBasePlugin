//
//  SSPluginActionModel.m
//  SSBasePlugin
//
//  Created by SunSet on 2017/11/28.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "SSPluginActionModel.h"

@implementation SSPluginActionModel


- (void)dealloc
{
    self.action_url = nil;
    self.action_type = nil;
    self.action_params = nil;
}


- (id)initWithActionType:(NSString *)actionType
            actionParams:(NSString *)actionParams
               actionUrl:(NSURL *)actionUrl
{
    if (self = [super init]) {
        _action_url = actionUrl;
        _action_type = actionType;
        _action_params = actionParams;
    }
    return self;
}



#pragma mark - NSCopying
// 
- (id)copyWithZone:(nullable NSZone *)zone
{
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    typeof(self) object = [[[self class] allocWithZone:zone] init];
    object.action_params = _action_params;
    object.action_type = _action_type;
    object.action_url = _action_url;
    return object;
}


#pragma mark - NSCoding
//
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_action_url forKey:@"action_url"];
    [aCoder encodeObject:_action_type forKey:@"action_type"];
    [aCoder encodeObject:_action_params forKey:@"action_params"];
}

//
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.action_params = [aDecoder decodeObjectForKey:@"action_params"];
        self.action_type = [aDecoder decodeObjectForKey:@"action_type"];
        self.action_url = [aDecoder decodeObjectForKey:@"action_url"];
    }
    return self;
}



@end



