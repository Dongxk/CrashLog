//
//  UncaughtExceptionHandler.m
//  CrashLog
//
//  Created by 董向坤 on 16/11/15.
//  Copyright © 2016年 董向坤. All rights reserved.
//

#import "UncaughtExceptionHandler.h"

#define DocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
NSString *applicationDocumentsDirectory() {

    return DocumentPath;
}

void Uncaughtexceptionhandler(NSException * exception){

    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


@implementation UncaughtExceptionHandler


// 沙盒地址
- (NSString *)applicationDocumentsDirectory {
    
    return DocumentPath;
}

+ (void)setDefaultHandler {
    
    NSSetUncaughtExceptionHandler( &Uncaughtexceptionhandler);
}

+ (NSUncaughtExceptionHandler *)getHandler {
    return NSGetUncaughtExceptionHandler();
}

+ (void)TakeException:(NSException *)exception {
  
    NSArray * arr = [exception callStackSymbols];
    NSString * reason = [exception reason];
    NSString * name = [exception name];
    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString * path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


@end
