//
//  BGRouterProtocol.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGRouterURLParameter.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BGRouterUrlCompletion)(BGRouterUrlResponse *urlResponse);

typedef void(^BGRouterUrlExecuteAction)(BGRouterUrlRequest *urlRequest, BGRouterUrlCompletion __nullable completetion);

/**
 路由拦截器协议
 */
@protocol BGRouterInterceptorProtocol <NSObject>

/**
 是否可以打开URL
 
 @discussion URL 默认是可以打开的.
 
 @param urlParttern 注册的URL
 @param parameter URL 参数
 @param msgBack 回调
 */
- (BOOL)bgRouterShouldOpenUrlParttern:(NSString *)urlParttern parameter:(NSDictionary<NSString *, NSString *> *)parameter msessageBack:(NSString * __nonnull *__nullable)msgBack;

- (BOOL)bgRouterWhetheExchangeUrlParttern:(NSString *)url parameter:(NSDictionary<NSString *, NSString *> *)parameter urlPartternBack:(NSString *__nonnull *__nullable)urlBack parameterBack:(NSDictionary * __nonnull *__nullable)paraBack messageBack:(NSString *__nonnull *__nullable)msgBack;

@end

/**
 路由辅助信息格式定义
 */
@protocol BGRouterMessageBodyProtocol <NSObject>
@property(nonatomic, readonly) NSString * eventName; ///< 事件名称
@property (nonatomic,readonly) NSUInteger eventIdentifier; ///< 事件数字表示
@property(nonatomic, readonly) NSString * eventMessage; ///< 事件信息
@end

/**
 路由辅助信息输出协议
 */
@protocol BGRouterMessageExportProtocol <NSObject>
@optional
- (void)bgRouterExcuteEvent:(__kindof NSObject<BGRouterMessageBodyProtocol> *)messageBody;

@end

@protocol BGRouterComponentRegisterProtocol <NSObject>

/**
 路由注册执行事件
 
 @discussion 用以在此事件中注册业务模块的多个路由事件
 
 */
+ (void)bgRouterRegisterExecute;

@end

NS_ASSUME_NONNULL_END
