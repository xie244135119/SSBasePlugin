//
//  SSBasePluginTests.m
//  SSBasePluginTests
//
//  Created by SunSet on 2017/8/24.
//  Copyright © 2017年 SunSet. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSPgyerPlugin.h"

@interface SSBasePluginTests : XCTestCase
{
    SSPgyerPlugin *_pgyerPlugin;            //
}
@end

@implementation SSBasePluginTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _pgyerPlugin = [[SSPgyerPlugin alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



- (void)testQueryBundleId
{
    // 测试页数
    NSString *bundleId = @"com.wdwd.android.cpos";
    [SSPgyerPlugin configPgyerApiKey:@"c5d6bea4ecdd76041fd87dd0b7e2e773" uKey:@"73605723e13be10ca670782500f6f58c"];
    
    
    // 查询
    [_pgyerPlugin test];
    
    
    // 等待运行结束
    while (YES) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
    }
    
}




- (void)testCompare
{
    NSString *version1 = @"1.0.9";
    NSString *version2 = @"1.1";
    NSString *version3 = @"1.0.8.5";
    
    
    NSLog(@" 比较结果%li %li %li ",[self compareVersion:version1 senderVersion:version2],[self compareVersion:version2 senderVersion:version3],[self compareVersion:version1 senderVersion:version3]);
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
        NSInteger count = (second.count-first.count);
        NSMutableArray *arry = count>0?first.mutableCopy:second.mutableCopy;
        int i = 0;
        while (i<labs(count)) {
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








