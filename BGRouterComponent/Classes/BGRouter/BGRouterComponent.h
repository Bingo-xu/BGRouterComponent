//
//  BGRouterComponent.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGRouterProtocol.h"
#import "BGRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGRouterComponent : NSObject

/**
 声明路由注册器
 
 @discussion 声明多个路由注册器, 使用路由注册器注册路由
 
 @param clsArr 注册器数组
 */
+ (void)bgDefineRouterregisters:(NSArray<Class<BGRouterComponentRegisterProtocol>> *)clsArr;

/**
 注册URL
 
 @param urlParttern url字符串
 @param urlExecuteAction url执行事件
 @param err 错误回调
 */
+ (BOOL)bgRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(BGRouterUrlExecuteAction)urlExecuteAction;

/**
 取消注册URL
 
 @param url url字符串
 */
+ (BOOL)bgDeregisterUrl:(NSString *)url;

/**
 清除注册过的路由
 */
+ (void)bgDeregisterAllUrls;

/**
 设置全局拦截器
 
 @discussion URL 在打开的过程中, 提供了全局拦截的机会, 用以支持通过拦截表来开启或关闭某些URL.
 
 @param globalInterceptor 全局拦截器
 */
+ (void)bgSetRouterGlobalInterceptor:(NSObject<BGRouterInterceptorProtocol> *)globalInterceptor;

/**
 设置消息输出器
 @param exporter 消息输出器
 */
+ (void)bgSetRouterMessageExporter:(NSObject<BGRouterMessageExportProtocol> *)exporter;

/**
 打开URL
 
 @param request 请求
 @param complete 回调
 */
+ (void)bgOpenUrl:(BGRouterUrlRequest *)request complete:(BGRouterUrlCompletion __nullable) complete;

/**
 打开URL
 
 @param urlInstance url
 @param fromVC 上级界面
 @param complete 回调
 */
+ (void)bgOpenUrlInstance:(NSString *)urlInstance fromVC:(UIViewController * __nullable)fromVC complete:(BGRouterUrlCompletion __nullable) complete;

/**
 检查是否可以开启URL
 
 @discussion 检查路由能否开启的时候,有3个要素:
 1. urlparttern 被取消了
 2. 精准匹配, 没有匹配到完整urlparttern的路由节点
 3. 模糊匹配, 没有匹配到任何可以用的路由节点.
 
 @param url URL
 @param parameters 参数
 @param absolute 绝对匹配/模糊匹配
 @param err 错误信息
 */
+ (BOOL)bgCanOpenUrl:(NSString *)url parameter:(NSDictionary * __nullable)parameters absolute:(BOOL)absolute error:(NSError *__nullable *__nullable)err;

# pragma mark - debug methods
+ (NSString *)bgRouterMapperJsonString;
+ (NSDictionary *)bgRouterMapperDict;

@end

NS_ASSUME_NONNULL_END
