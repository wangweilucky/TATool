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
#import <CoreMotion/CoreMotion.h>

FMDatabase *__ta_db;

@interface TALoggerManager ()

@property (strong,nonatomic) CMMotionManager *motionManager;

@end

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
    
    [self share];
    
    [self createDataBase];
    [self executeMuchSql];
    
    [NSClassFromString(@"TDAbstractLogger") aspect_hookSelector:@selector(logMessage:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        NSLog(@"%@: ######### type:%@ message:%@", aspectInfo.instance, [aspectInfo.arguments.lastObject valueForKey:@"type"], [aspectInfo.arguments.lastObject valueForKey:@"message"]);
        
        NSString *message = (NSString *)[aspectInfo.arguments.lastObject valueForKey:@"message"];
        NSInteger type = [[aspectInfo.arguments.lastObject valueForKey:@"type"] integerValue];
        message = [NSString stringWithFormat:@"[THINKING] %@", message];
        
        [self write:message type:type];
        
    } error:NULL];
 
}

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static TALoggerManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [TALoggerManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];//一般在viewDidLoad中进行
        self.motionManager.accelerometerUpdateInterval = .1;//加速仪更新频率，以秒为单位
        [self startAccelerometer];
    }
    return self;
}

-(void)startAccelerometer
{
  //以push的方式更新并在block中接收加速度
  [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc]init]
     withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
      [self outputAccelertionData:accelerometerData.acceleration];
  }];
}
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
  //综合3个方向的加速度
  double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 )
     + pow( acceleration.z , 2) );
  //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
  if (accelerameter>4.f) {
 //立即停止更新加速仪（很重要！）
//    [self.motionManager stopAccelerometerUpdates];
     
      dispatch_async(dispatch_get_main_queue(), ^{
          [[self class] show];
      });
  }
    
    
    
}

+ (void)show {
    TALoggerController *vc = [[TALoggerController alloc] init];
    vc.title = @"logger";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

@end
