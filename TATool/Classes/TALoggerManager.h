//
//  TALoggerManager.h
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/6/13.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TALoggerManager : NSObject


+ (void)createDataBase;

+ (void)executeMuchSql;

+ (void)write:(NSString *)message type:(NSInteger)type;

+ (NSArray *)search;

@end

NS_ASSUME_NONNULL_END
