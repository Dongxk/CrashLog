//
//  UncaughtExceptionHandler.h
//  CrashLog
//
//  Created by 董向坤 on 16/11/15.
//  Copyright © 2016年 董向坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject


+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *)exception;

@end
