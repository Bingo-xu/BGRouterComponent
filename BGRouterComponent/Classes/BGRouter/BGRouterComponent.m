//
//  BGRouterComponent.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGRouterComponent.h"
#import "BGRouterMessageBody.h"
#import "BGRouterMapperNode.h"
#import "BGAnnotatorComponent.h"
#import "BGRouterErrorHelper.h"

@interface BGRouterComponent ()

@property(nonatomic, strong) BGRouterMapperNode *routerNodesMap; ///< 路由表--事件
@property(nonatomic, strong) NSObject <BGRouterInterceptorProtocol> *globalInterceptor; ///< 全局拦截器
@property (nonatomic, strong) NSObject<BGRouterMessageExportProtocol> * messageExporter; ///< 消息输出器

@end

@implementation BGRouterComponent

+ (BGRouterComponent *)shareInstance {
    if (![BGAnnotatorComponent new].routerInstance) {
        BGRouterComponent *service = [BGRouterComponent new];
        service.routerNodesMap = [BGRouterMapperNode new];
        [BGAnnotatorComponent new].routerInstance = service;
    }
    return [BGAnnotatorComponent new].routerInstance;
}

- (void)initRouterConfig {
    if (self.routerNodesMap.isNodesEmpty) { //没有节点
        @synchronized (self) {
            if (self.routerNodesMap.isNodesEmpty) { //没有节点
                NSArray<BGAnnotatorDataFunc *> *funcs = [[BGAnnotatorComponent new].annotationFuncsDict objectForKey:[[NSString alloc] initWithCString:BGRouterComponentFlag encoding:NSUTF8StringEncoding]];
                [funcs enumerateObjectsUsingBlock:^(BGAnnotatorDataFunc *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    /**
                     1. 此处一次性执行所有路由的注册函数.
                     2. 后期可以考虑做优化, 每个路由第一次被调用的时候,才执行它的注册函数, 提升时间效率.[借助YKAnnotationRegisterSEL宏的externStr 字段, 实现url 与 执行函数的映射]
                     */
                    obj.bgMacho_O_method();
                }];
            }
        }
    }
}

/**
 声明路由注册器
 
 @discussion 声明多个路由注册器, 使用路由注册器注册路由
 
 @param clsArr 注册器数组
 */
+ (void)bgDefineRouterregisters:(NSArray<Class<BGRouterComponentRegisterProtocol>> *)clsArr {
    [clsArr enumerateObjectsUsingBlock:^(Class<BGRouterComponentRegisterProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(BGRouterComponentRegisterProtocol)]){
            [obj bgRouterRegisterExecute];
        }else{
            NSError *err = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeNoUrl info:nil message:@"路由检查能否开启失败,发起方未接受异常信息"];
             [self bg_showRouterError:err];
        }
    }];
}

/**
 注册URL
 
 @param urlParttern url字符串
 @param urlExecuteAction url执行事件
 @param err 错误回调
 */
+ (BOOL)bgRegisterUrlPartterns:(NSString *)urlParttern error:(NSError **)err action:(BGRouterUrlExecuteAction)urlExecuteAction {
    [self bg_exportEventMessageWithId:BGRouterEventIdTypeRegisterUrl message:urlParttern];
    BOOL result = NO;
    result = [[self shareInstance].routerNodesMap ykInsertOneNodeWithUrl:urlParttern executeAction:urlExecuteAction error:err];
    return result;
}

/**
 取消注册URL
 @param url url字符串
 */
+ (BOOL)bgDeregisterUrl:(NSString *)url {
    NSError *err;
    BGRouterMapperNode *node = [[self shareInstance].routerNodesMap bgSearchNodeWithUrl:url absoluteFlag:YES error:&err];
    [node bgDeregisteNode];
    return YES;
}

/**
 清除注册过的路由
 */
+ (void)bgDeregisterAllUrls {
    [[self shareInstance].routerNodesMap bgCleanNodes];
}

/**
 设置全局拦截器
 
 @discussion URL 在打开的过程中, 提供了全局拦截的机会, 用以支持通过拦截表来开启或关闭某些URL.
 
 @param globalInterceptor 全局拦截器
 */
+ (void)bgSetRouterGlobalInterceptor:(NSObject<BGRouterInterceptorProtocol> *)globalInterceptor {
    [self shareInstance].globalInterceptor = globalInterceptor;
}

/**
 设置消息输出器
 @param exporter 消息输出器
 */
+ (void)bgSetRouterMessageExporter:(NSObject<BGRouterMessageExportProtocol> *)exporter {
    [self shareInstance].messageExporter = exporter;
}

/**
 打开URL
 
 @param request 请求
 @param complete 回调
 */
+ (void)bgOpenUrl:(BGRouterUrlRequest *)request complete:(BGRouterUrlCompletion __nullable) complete {
    [self bg_exportEventMessageWithId:BGRouterEventIdTypeOpenUrl message:request.url];
    NSError *err = nil;
    BGRouterUrlRequest *requestUsing = nil;
    
    BGRouterMapperNode *node = [[self shareInstance] bg_filterUrNodeWithRequest:[request copy] requestBack:&requestUsing error:&err];
    
    if (err) { //失败
        [self bg_showRouterError:err];
        BGRouterUrlResponse *response = [BGRouterUrlResponse instanceWithBuilder:^(BGRouterUrlResponse * _Nonnull response) {
            response.err = err;
            response.msg =  err.localizedDescription;
            response.status = err.code;
        }];
        
        if (complete) complete(response);
        return;
    }
    
    BGRouterUrlExecuteAction action = node.executeAction;
    if (action){
        BGRouterUrlCompletion com = ^(BGRouterUrlResponse *urlResponse){ //此处只是为了方便调试.
            if (complete) complete(urlResponse);
        };
        action(requestUsing, com);
        
    }else{
        NSError *err = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeNoUrl info:nil message:@"路由失败,注册的路由没有设置响应事件"];
        [self bg_showRouterError:err];
    }
}

/**
 打开URL
 
 @param urlInstance url
 @param fromVC 上级界面
 @param complete 回调
 */
+ (void)bgOpenUrlInstance:(NSString *)urlInstance fromVC:(UIViewController * __nullable)fromVC complete:(BGRouterUrlCompletion __nullable) complete {
    BGRouterUrlRequest *request = [BGRouterUrlRequest instanceWithBuilder:^(BGRouterUrlRequest * _Nonnull builder) {
        builder.url = urlInstance;
        builder.fromVC = fromVC;
    }];
    [self bgOpenUrl:request complete:complete];
}

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
+ (BOOL)bgCanOpenUrl:(NSString *)url parameter:(NSDictionary * __nullable)parameters absolute:(BOOL)absolute error:(NSError *__nullable *__nullable)err {
    NSError *errBack = nil;
    BGRouterUrlRequest *request = [BGRouterUrlRequest instanceWithBuilder:^(BGRouterUrlRequest * _Nonnull builder) {
        builder.url = url; builder.parameter = parameters;
    }];
    
    [[self shareInstance] bg_filterUrNodeWithRequest:request requestBack:nil error:&errBack];
    
    if (errBack) {
        if (err) {
            *err = errBack;
        } else { //业务失败,发送方未判断错误, 此处在终端和日志系统中反馈一下
           NSError *err = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeNoUrl info:nil message:@"路由检查能否开启失败,发起方未接受异常信息"];
            [self bg_showRouterError:err];
        }
        return NO;
    }
    return YES;
}



# pragma mark - debug methods
+ (NSString *)bgRouterMapperJsonString {
    return [[self shareInstance].routerNodesMap bgRouterMapperJsonString];
}

+ (NSDictionary *)bgRouterMapperDict {
    return [[self shareInstance].routerNodesMap bgRouterMapperDict];
}

# pragma mark - work methods
//BGRouterUrlRequest
- (BGRouterMapperNode *)bg_filterUrNodeWithRequest:(BGRouterUrlRequest*)request requestBack:(BGRouterUrlRequest **)requestBack error:(NSError **)err {
    [self initRouterConfig];
    
    NSString *url = request.url;
    NSDictionary *paramaters = request.parameter;
    BOOL absolute = request.absolute;
    
    BGRouterURLParameter *parser = [BGRouterURLParameter bgParserUrl:request.url parameter:request.parameter];
    NSMutableDictionary *para = [NSMutableDictionary new];
    [para addEntriesFromDictionary:[parser queryparamaters]];
    [request.parameter enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSString *value = [[NSString stringWithFormat:@"%@", obj] stringByRemovingPercentEncoding];
        [para setObject:value forKey:key];
    }];
    
    NSString *interceptorMes = nil;
    /** 此处需要进入全局拦截流程 */
    if ([self.globalInterceptor respondsToSelector:@selector(bgRouterShouldOpenUrlParttern:parameter:msessageBack:)]) {
        // 全局判断是否可打开URL
        BOOL result = [self.globalInterceptor bgRouterShouldOpenUrlParttern:parser.urlParttern parameter:para msessageBack:&interceptorMes];
        if (!result) { //url 不能被打开
            NSString *errMsg = interceptorMes.length ? interceptorMes : [NSString stringWithFormat:@"Url was closed by server:[%@]", [parser.url stringByRemovingPercentEncoding]];
            NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeUrlClosed info:nil message:errMsg];
            
            if (err) *err = errBack;
            return nil;
        }
    }
    
    if ([self.globalInterceptor respondsToSelector:@selector(bgRouterWhetheExchangeUrlParttern:parameter: urlPartternBack: parameterBack:messageBack:)]) {
        // 全局拦截去, URL是否被切换
        NSDictionary *paraUsed = nil;
        NSString *urlUsed = nil;
        BOOL exchangeFlag = [self.globalInterceptor bgRouterWhetheExchangeUrlParttern:parser.urlParttern parameter:para urlPartternBack:&urlUsed parameterBack:&paraUsed messageBack:&interceptorMes];
        if (exchangeFlag) { //URL 或者 参数 被交换了
            url = urlUsed;
            para = [paraUsed mutableCopy];
        }
    }
    
    NSError *errBack;
    BGRouterMapperNode *node = [self.routerNodesMap bgSearchNodeWithUrl:parser.urlPartternFull absoluteFlag:absolute error:&errBack];
    
    if (errBack) { //没有找到节点
        if (err) *err = errBack;
        return nil;
    }
    
    paramaters = para;
    NSURLComponents *componentSource = [NSURLComponents componentsWithString:parser.urlPartternFull];
    
    //重组URL, 将paramaters参数变为 query
    NSMutableArray<NSURLQueryItem *> *queryArr = [NSMutableArray new];
    [queryArr addObjectsFromArray:componentSource.queryItems];
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        NSString *value = [[NSString stringWithFormat:@"%@", obj] stringByRemovingPercentEncoding];
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
        [queryArr addObject:item];
    }];
    queryArr.count ? componentSource.queryItems = queryArr : 0;
    NSString *urlBack = componentSource.URL.absoluteString;
    
    NSString *urlPartternBack = parser.urlParttern;
    
    if (requestBack) {
        BGRouterUrlRequest *request_used = [request copy];
        request_used.url = urlBack;
        request_used.urlParttern = urlPartternBack;
        request_used.parameter = paramaters;
        request_used.paraOrignal = request.parameter;
        *requestBack = request_used;
    }
    
    return node;
}

+ (void)bg_exportEventMessageWithId:(NSInteger)eventId message:(NSString *)msg {
    BGRouterMessageBody *body = [BGRouterMessageBody new];
    body.eventIdentifier = eventId; body.eventMessage = msg;
    if ([[self shareInstance].messageExporter respondsToSelector:@selector(bgRouterExcuteEvent:)]) {
        [[self shareInstance].messageExporter bgRouterExcuteEvent:body];
    }
}

+ (void)bg_showRouterError:(NSError *)err {
#ifdef DEBUG
    NSString *msg = [NSString stringWithFormat:@"%@", err];
    NSLog(@"%@",msg);
#endif
}

@end
