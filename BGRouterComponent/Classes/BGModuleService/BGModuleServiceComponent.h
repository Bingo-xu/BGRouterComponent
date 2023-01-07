//
//  BGModuleServiceComponent.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGModuleServiceHeader.h"

NS_ASSUME_NONNULL_BEGIN

/// 服务组件标识
#define BGModuleComponent_flag "BGModuleComponent_flag"

#define BGModuleServiceRegister() BGAnnotatorRegisterSEL(BGModuleComponent_flag, "module_future")

@interface BGModuleServiceComponent : NSObject

/**
 注册服务
 @param cls 服务类
 @param protocol 服务协议
 @param error 错误信息
 */
+ (BOOL)bgRegisterModuleServiceWith:(Class)cls protocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error;

/**
 获取服务
 
 @param protocol 服务协议
 @param error 错误信息
 */
+ (__kindof Class)bgGetModuleServiceWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error;

@end

NS_ASSUME_NONNULL_END
