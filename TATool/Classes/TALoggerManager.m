//
//  TALoggerManager.m
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/6/13.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TALoggerManager.h"
#import "Aspects.h"
#import "FMDB.h"
#import "TALoggerController.h"

FMDatabase *__ta_db;

@implementation TALoggerManager

+ (void)createDataBase {
    // 获取数据库文件的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:@"TALogger.sqlite"];
    NSLog(@"path = %@",path);
    // 1..创建数据库对象
    __ta_db = [FMDatabase databaseWithPath:path];
    // 2.打开数据库
    if (![__ta_db open]) {
        NSLog(@"fail to open database");
    }
}

+ (void)executeMuchSql {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:@"TALogger.sqlite"];
    NSLog(@"path = %@",path);
    
    // 1..创建数据库对象
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    // 2.打开数据库
    if ([db open]) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS t_ta_logger (id integer PRIMARY KEY AUTOINCREMENT, message text, type int, time text);";
        [db executeStatements:sql];
    }
}

+ (void)write:(NSString *)message type:(NSInteger)type {
    NSString *sql = @"insert into t_ta_logger (message, type, time) values (?, ?, ?)";
    NSString *time = [self currentDateStr];
    [__ta_db executeUpdate:sql, message, @(type), time];
}

+ (void)delete {
    NSString *sql = @"delete from t_ta_logger where id = ?";
    [__ta_db executeUpdate:sql, [NSNumber numberWithInt:1]];
}

+ (NSArray *)search {
    NSString *sql = @"select id, message, type, time FROM t_ta_logger";
    FMResultSet *rs = [__ta_db executeQuery:sql];
    NSMutableArray *arr = [NSMutableArray array];
    while ([rs next]) {
        int idd = [rs intForColumnIndex:0];
        NSString *message = [rs stringForColumnIndex:1];
        int type = [rs intForColumnIndex:2];
        NSString *time = [rs stringForColumnIndex:3];
        NSDictionary *dic = @{@"message":message, @"type":@(type), @"time":time};
        [arr addObject:dic];
    }
    return arr;
}

//获取当前时间
+ (NSString *)currentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];// 创建一个时间格式化对象
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
    NSString *dateString = [dateFormatter stringFromDate:currentDate];//将时间转化成字符串
    return dateString;
}


+ (void)load {
    
    [self createDataBase];
    [self executeMuchSql];
    
    [NSClassFromString(@"TDAbstractLogger") aspect_hookSelector:@selector(logMessage:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        NSLog(@"%@: ######### type:%@ message:%@", aspectInfo.instance, [aspectInfo.arguments.lastObject valueForKey:@"type"], [aspectInfo.arguments.lastObject valueForKey:@"message"]);
        
        NSString *message = (NSString *)[aspectInfo.arguments.lastObject valueForKey:@"message"];
        NSInteger type = [[aspectInfo.arguments.lastObject valueForKey:@"type"] integerValue];
        message = [NSString stringWithFormat:@"[THINKING] %@", message];
        
        [self write:message type:type];
        
    } error:NULL];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TALoggerController *vc = [[TALoggerController alloc] init];
        vc.title = @"logger";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
    });
}

@end
