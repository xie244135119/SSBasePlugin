//
//  SSPgyerPlugin.m
//  SSBasePlugin
//
//  Created by SunSet on 2017/7/13.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "SSPgyerPlugin.h"
#import <SSBaseLib/SSBaseLib.h>


// 配置项 {"pro":{"kPgyerAppKey":"kPgyerUKey","":""},"dev":{"kPgyerAppKey":"kPgyerUKey","":""}}
static NSMutableDictionary * kPgyerAppConfig = nil;

static NSString *const kPgyerApiKey = @"kPgyerApiKey";

// 蒲公英返回的结构体
@interface SSPgyerAppModel: AMDBaseModel

#pragma mark - Apv1(蒲公英1.0接口)

#pragma mark - Apv1(蒲公英2.0接口)
// 返回应用最新build Key
@property(nonatomic, copy) NSString *buildKey;
// 应用类型（1:iOS; 2:Android）
@property(nonatomic, strong) NSNumber *buildType;
// App 文件大小
@property(nonatomic, strong) NSNumber *buildFileSize;
// 应用名称
@property(nonatomic, copy) NSString *buildName;
// 版本号
@property(nonatomic, copy) NSString *buildVersion;
// 上传包的版本编号
@property(nonatomic, copy) NSString *buildVersionNo;
// 蒲公英生成的用于区分历史版本的build号
@property(nonatomic, strong) NSNumber *buildBuildVersion;
// 应用程序包名，iOS为BundleId，Android为包名
@property(nonatomic, copy) NSString *buildIdentifier;
// 应用的Icon图标key，访问地址为 https://www.pgyer.com/image/view/app_icons/[应用的Icon图标key]
@property(nonatomic, copy) NSString *buildIcon;
// 应用上传时间
@property(nonatomic, copy) NSString *buildCreated;
// 应用介绍
@property(nonatomic, copy) NSString *buildDescription;
// 应用更新说明
@property(nonatomic, copy) NSString *buildUpdateDescription;
// 应用短链接
@property(nonatomic, copy) NSString *buildShortcutUrl;

@end



@interface SSPgyerPlugin()
{
    NSInteger _requestPage;             //请求的页数
}
@end

@implementation SSPgyerPlugin

- (void)dealloc
{
    //
}


#pragma mark - public api
// 配置
+ (void)configPgyerApiKey:(NSString *)appKey
{
    if (kPgyerAppConfig == nil) {
        kPgyerAppConfig = [[NSMutableDictionary alloc]init];
    }
    [kPgyerAppConfig setObject:@{kPgyerApiKey:appKey} forKey:@"pro"];
}

+ (void)configPgyerDevApiKey:(NSString *)appKey
{
    if (kPgyerAppConfig == nil) {
        kPgyerAppConfig = [[NSMutableDictionary alloc]init];
    }
    [kPgyerAppConfig setObject:@{kPgyerApiKey:appKey} forKey:@"dev"];
}


- (void)start
{
    // 蒲公英自动更新
    _requestPage = 1;
    [self _invokeLaterVersionWithPage:1];
}



#pragma mark - SSModuleProtrol
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    // 
    [self start];
    
    return YES;
}


//- (void)test
//{
//    [self application:nil didFinishLaunchingWithOptions:nil];
//}


// 当前的AppKey
- (NSString *)_apiKey
{
    // 自己的测试账号
    NSString *_api_key = kPgyerAppConfig[@"pro"][kPgyerApiKey];
#ifdef DEBUG
    if (kPgyerAppConfig[@"dev"]) {
        _api_key = kPgyerAppConfig[@"dev"][kPgyerApiKey];
    }
#endif
    return _api_key;
}


#pragma mark - private api
// 获取我当前账号下所有发布的app
- (void)_invokeLaterVersionWithPage:(NSInteger)page
{
    NSString *paramstr = [[NSString alloc]initWithFormat:@"_api_key=%@&page=%li",[self _apiKey],(long)page];
    __weak typeof(self) weakself = self;
    NSString *urlstr = @"https://www.pgyer.com/apiv2/app/listMy";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlstr]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [paramstr dataUsingEncoding:4];
    NSURLSessionDataTask *tasdk = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)response;
        if (httpresponse.statusCode == 200) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [weakself _handleResponse:responseObject];
        }
    }];
    [tasdk resume];
}

// 安装App
- (void)_invokeInstallAppWithKey:(NSString *)buildKey
{
    NSString *password = @"123456";
    NSString *urlstr = [[NSString alloc]initWithFormat:@"https://www.pgyer.com/apiv2/app/install?buildKey=%@&_api_key=%@&password=%@",buildKey,[self _apiKey],password];
    NSURL *url = [NSURL URLWithString:urlstr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}



// 处理
// 开发模式下取小版本发布 调试模式下取大版本发布
- (void)_handleResponse:(NSDictionary *)response
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 查询结果
        BOOL _querysuccess = NO;
        if ([response[@"code"] intValue]== 0) {

            NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
            NSArray *list = response[@"data"][@"list"];
            for (NSDictionary *app in list) {
                SSPgyerAppModel *model = [[SSPgyerAppModel alloc]initWithDictionary:app error:nil];
                if(model.buildType.intValue == 2) continue;
                // 当前app
                if ([model.buildIdentifier isEqualToString:bundleid]) {
                    _querysuccess = YES;
                    // 处理找的蒲公英 Model
                    [self _handlePgyerAppModel:model];
                    
                    break;
                }
            }
            
            // 继续第二页查询
            if (!_querysuccess) {
                _requestPage ++;
                // 请求页
                [weakself _invokeLaterVersionWithPage:_requestPage];
            }
        }
    });
}


#pragma mark - 升级提示框
// 获取到蒲公英 model
- (void)_handlePgyerAppModel:(SSPgyerAppModel *)model
{
    // 比较版本号是否有更新
#ifdef DEBUG
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if ([SSPgyerPlugin compareVersion:model.buildVersionNo senderVersion:version] == NSOrderedDescending) {
        NSString *title = @"蒲公英有更新嘞";
        NSString *message = model.buildUpdateDescription;
#else
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    if ([SSPgyerPlugin compareVersion:model.buildVersion senderVersion:version] == NSOrderedDescending) {
        NSString *title = [[NSString alloc]initWithFormat:@"有新版本啦 V%@",model.buildVersion];
        NSString *message = nil;
#endif
        __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 提示框 这里使用View 视图是防止和其他Controller模态展现产生冲突
                void (^_finish)(UIAlertAction *action) = ^(UIAlertAction * _Nonnull action) {
                    // 不使用itemsservices appstore过审失败
//                    NSString *urlstr = [[NSString alloc]initWithFormat:@"itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/%@",model.appKey];
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
                    [weakself _invokeInstallAppWithKey:model.buildKey];
                };
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:weakself cancelButtonTitle:@"先逛逛" otherButtonTitles:@"查看", nil];
                [alertView bindValue:_finish forKey:@"block"];
                [alertView show];
                
            });
        }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 安装
    if (buttonIndex == 1) {
        void (^_finish)(UIAlertAction *action) = [alertView getBindValueForKey:@"block"];
        _finish(nil);
    }
}


    
#pragma mark - public api
                   
// 前者和后者版本号比较
+ (NSComparisonResult)compareVersion:(NSString *)version
senderVersion:(NSString *)senderVersion
{
    // 思路： 将版本号转为数字判断 以点拆分，位数不够补0
     if ([version isEqualToString:senderVersion]) {
            return NSOrderedSame;
    }
        
    NSArray *first = [version componentsSeparatedByString:@"."];
    NSArray *second = [senderVersion componentsSeparatedByString:@"."];
    if (first.count != second.count) {
        NSInteger count = (second.count-first.count);
        NSMutableArray *arry = count>0?first.mutableCopy:second.mutableCopy;
        int i = 0;
        while (i<labs(count)) {
            [arry addObject:@"0"];
            i++;
        }
        count>0?(first=arry):(second=arry);
    }
    
    BOOL resault = YES;
    for (int i =0; i<first.count; i++) {
        NSString *a1 = first[i];
        NSString *a2 = second[i];
        if (a1.integerValue == a2.integerValue) {
            continue;
        }
        resault = a1.integerValue > a2.integerValue ;
        break;
    }
    return resault ? NSOrderedDescending:NSOrderedAscending;
}



@end



@implementation SSPgyerAppModel

- (void)dealloc
{
    self.buildVersionNo = nil;
    self.buildKey = nil;
    self.buildUpdateDescription = nil;
    self.buildIdentifier = nil;
    self.buildName = nil;
    self.buildType = nil;
    self.buildIcon = nil;
    self.buildCreated = nil;
    self.buildDescription = nil;
}

@end





