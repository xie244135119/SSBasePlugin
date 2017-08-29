//
//  SSPgyerPlugin.m
//  AppMicroDistribution
//
//  Created by SunSet on 2017/7/13.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import "SSPgyerPlugin.h"
#import <SSBaseLib/SSBaseLib.h>


// 配置项 {"pro":{"kPgyerAppKey":"kPgyerUKey","":""},"dev":{"kPgyerAppKey":"kPgyerUKey","":""}}
static NSMutableDictionary * kPgyerAppConfig = nil;

static NSString *const kPgyerApiKey = @"kPgyerApiKey";
static NSString *const kPgyeruKey = @"kPgyeruKey";

// 蒲公英返回的结构体
@interface SSPgyerAppModel: AMDBaseModel

// 返回应用最新build的App Key
@property(nonatomic, copy) NSString *appKey;
// 应用类型（1:iOS; 2:Android）
@property(nonatomic, strong) NSNumber *appType;
// App 文件大小
@property(nonatomic, strong) NSNumber *ppFileSize;
// 应用名称
@property(nonatomic, copy) NSString *appName;
// 版本号
@property(nonatomic, copy) NSString *appVersion;
// 适用于Android的版本编号，iOS始终为0
@property(nonatomic, copy) NSString *appVersionNo;
// 蒲公英生成的用于区分历史版本的build号
@property(nonatomic, copy) NSString *appBuildVersion;
// 应用程序包名，iOS为BundleId，Android为包名
@property(nonatomic, copy) NSString *appIdentifier;
// 应用的Icon图标key
@property(nonatomic, copy) NSString *appIcon;
// app描述
@property(nonatomic, copy) NSString *appDescription;
// 更新介绍
@property(nonatomic, copy) NSString *appUpdateDescription;
// 截图
@property(nonatomic, copy) NSString *appScreenshots;
// 创建时间
@property(nonatomic, copy) NSString *appCreated;

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
                     uKey:(NSString *)uKey
{
    if (kPgyerAppConfig == nil) {
        kPgyerAppConfig = [[NSMutableDictionary alloc]init];
    }
    
    [kPgyerAppConfig setObject:@{kPgyerApiKey:appKey, kPgyeruKey:uKey} forKey:@"pro"];
}

+ (void)configPgyerDevApiKey:(NSString *)appKey
                     devUKey:(NSString *)uKey
{
    if (kPgyerAppConfig == nil) {
        kPgyerAppConfig = [[NSMutableDictionary alloc]init];
    }
    
    [kPgyerAppConfig setObject:@{kPgyerApiKey:appKey, kPgyeruKey:uKey} forKey:@"dev"];
}





#pragma mark - SSModuleProtrol
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    // 蒲公英自动更新
    _requestPage = 1;
    [self _invokeLaterVersionWithPage:1];
    
    return YES;
}


- (void)test
{
    [self application:nil didFinishLaunchingWithOptions:nil];
}


#pragma mark - private api
// 获取我当前账号下所有发布的app
- (void)_invokeLaterVersionWithPage:(NSInteger)page
{
    // 账号相关
    // 自己的测试账号
    NSString *_api_key = kPgyerAppConfig[@"pro"][kPgyerApiKey];
    NSString *uKey =  kPgyerAppConfig[@"pro"][kPgyeruKey];
    
#ifdef DEBUG
    if (kPgyerAppConfig[@"dev"]) {
        _api_key = kPgyerAppConfig[@"dev"][kPgyerApiKey];
        uKey =  kPgyerAppConfig[@"dev"][kPgyeruKey];
    }
#endif
    
    NSString *paramstr = [[NSString alloc]initWithFormat:@"uKey=%@&_api_key=%@&page=%li",uKey,_api_key,page];
    __weak typeof(self) weakself = self;
    NSString *urlstr = @"http://www.pgyer.com/apiv1/user/listMyPublished";
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
                if(model.appType.intValue == 2) continue;
                // 当前app
                if ([model.appIdentifier isEqualToString:bundleid]) {
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


// 获取到蒲公英 model
- (void)_handlePgyerAppModel:(SSPgyerAppModel *)model
{
    // 比较版本号是否有更新
#ifdef DEBUG
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if ([self compareVersion:model.appVersionNo senderVersion:version] == NSOrderedDescending) {
        NSString *title = @"蒲公英有更新嘞";
        NSString *message = model.appUpdateDescription;
#else
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    if ([self compareVersion:model.appVersion senderVersion:version] == NSOrderedDescending) {
        NSString *title = [[NSString alloc]initWithFormat:@"有新版本啦 V%@",model.appVersion];
        NSString *message = nil;
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //
                UIAlertAction *showaction = [UIAlertAction actionWithTitle:@"先逛逛" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *installaction = [UIAlertAction actionWithTitle:@"安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSString *urlstr = [[NSString alloc]initWithFormat:@"itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/%@",model.appKey];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstr]];
                }];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:showaction];
                [alert addAction:installaction];
                
                [[self navcontroller] presentViewController:alert animated:YES completion:nil];
            });
        }
}

    
// 导航控制器
- (UINavigationController *)navcontroller
{
    id app = [[UIApplication sharedApplication] delegate];
    return (UINavigationController *)[[app window] rootViewController];
}

    
    
#pragma mark - public api
                   
// 前者和后者版本号比较
- (NSComparisonResult)compareVersion:(NSString *)version
                       senderVersion:(NSString *)senderVersion
{
    // 思路： 将版本号转为数字判断 以点拆分，位数不够补0
    if ([version isEqualToString:senderVersion]) {
        return NSOrderedSame;
    }
    
    NSArray *first = [version componentsSeparatedByString:@"."];
    NSArray *second = [senderVersion componentsSeparatedByString:@"."];
    if (first.count != second.count) {
        NSInteger count = second.count-first.count;
        NSMutableArray *arry = count>0?first.mutableCopy:second.mutableCopy;
        int i = 0;
        while (i<count) {
            [arry addObject:@"0"];
            i++;
        }
        count>0?(first=arry):(second=arry);
    }
    NSInteger firstversion = [[first componentsJoinedByString:@""] integerValue];
    NSInteger secondversion = [[second componentsJoinedByString:@""] integerValue];
    return firstversion>secondversion?NSOrderedDescending:NSOrderedAscending;
}



@end



@implementation SSPgyerAppModel

- (void)dealloc
{
    self.appKey = nil;
    self.appVersionNo = nil;
    self.appIdentifier = nil;
    self.appIcon = nil;
    self.appName = nil;
    self.appUpdateDescription = nil;
    self.appCreated = nil;
    self.appVersion = nil;
    self.appDescription = nil;
    self.appScreenshots = nil;
}

@end





