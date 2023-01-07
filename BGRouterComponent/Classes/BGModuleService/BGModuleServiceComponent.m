//
//  BGModuleServiceComponent.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGModuleServiceComponent.h"
#import <pthread/pthread.h>
#import "BGAnnotatorComponent.h"
#import "BGModuleServiceHelper.h"

@interface BGModuleServiceComponent()
{
    pthread_rwlock_t _lock_bgRWLock; ///< 读写锁
}
/**模块表**/
@property (nonatomic, strong) NSMapTable<Protocol *, Class> *modulesMap;

@end

@implementation BGModuleServiceComponent

+ (BGModuleServiceComponent *)shareInstance {
    if (![BGAnnotatorComponent new].serviceInstance) {
        BGModuleServiceComponent *service = [BGModuleServiceComponent new];
        service.modulesMap = [NSMapTable strongToStrongObjectsMapTable];
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        service->_lock_bgRWLock = lock;
        [BGAnnotatorComponent new].serviceInstance = service;
    }
    return [BGAnnotatorComponent new].serviceInstance;
}

/**
 注册服务
 @param cls 服务类
 @param protocol 服务协议
 @param error 错误信息
 */
+ (BOOL)bgRegisterModuleServiceWith:(Class)cls protocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error {
    return [[BGModuleServiceComponent shareInstance] bgRegisterModuleServiceWith:cls protocol:protocol error:error];
}

/**
 获取服务
 
 @param protocol 服务协议
 @param error 错误信息
 */
+ (__kindof Class)bgGetModuleServiceWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error {
    return [[BGModuleServiceComponent shareInstance] bgGetModuleServiceWithProtocol:protocol error:error];
}


/**
 注册服务
 @param cls 服务类
 @param protocol 服务协议
 @param error 错误信息
 */
- (BOOL)bgRegisterModuleServiceWith:(Class)cls protocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error {
    if (!cls || !protocol) { //没有类或协议
        NSString *msg = [NSString stringWithFormat:@"No module class or module protocol, while registing module."];
        NSError *errBack = [BGModuleServiceHelper bg_createServiceError:1 info:nil message:msg];
        if (error) *error = errBack;
        NSAssert(0, msg);
        return NO;
    }
    
    pthread_rwlock_rdlock(&(self->_lock_bgRWLock)); ////读加锁
    Class existCls = [self.modulesMap objectForKey:protocol];
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 读解锁

    if ([existCls isEqual:cls]) { //已经注册过
        NSString *msg = [NSString stringWithFormat:@"Class[%@] has been regist with protocol:[%@]", existCls, protocol];
        NSError *errBack = [BGModuleServiceHelper bg_createServiceError:1 info:nil message:msg];
        if (error) *error = errBack;
        NSAssert(0, msg);
        return NO;
    }
    
    pthread_rwlock_wrlock(&(self->_lock_bgRWLock)); /// 写加锁
    [self.modulesMap setObject:cls forKey:protocol];
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 写解锁
    
    return YES;
}

/**
 获取服务
 
 @param protocol 服务协议
 @param error 错误信息
 */
- (__kindof Class)bgGetModuleServiceWithProtocol:(Protocol *)protocol error:(NSError *__nullable *__nullable)error {
    [self initModuleConfig];
    pthread_rwlock_rdlock(&(self->_lock_bgRWLock)); ////读加锁
    Class cls = [self.modulesMap objectForKey:protocol];
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 读解锁
    if (!cls) {
        NSString *msg = [NSString stringWithFormat:@"No class for protocol[%@], while get module.", protocol];
        NSError *errBack = [BGModuleServiceHelper bg_createServiceError:1 info:nil message:msg];
        if (error) *error = errBack;
    }
    return cls;
}

# pragma mark - work methods
- (void)initModuleConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<BGAnnotatorDataFunc *> * funcs = [[BGAnnotatorComponent new].annotationFuncsDict objectForKey:[[NSString alloc] initWithCString:BGModuleComponent_flag encoding:NSUTF8StringEncoding]];
        [funcs enumerateObjectsUsingBlock:^(BGAnnotatorDataFunc * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /**
             1. 此处一次性执行所有路由的注册函数.
             2. 后期可以考虑做优化, 每个路由第一次被调用的时候,才执行它的注册函数, 提升时间效率.[借助BGAnnotatorRegisterSEL宏的externStr 字段, 实现url 与 执行函数的映射]
             */
            obj.bgMacho_O_method();
        }];
    });
}


@end
