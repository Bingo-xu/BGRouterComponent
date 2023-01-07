//
//  BGRouterMapperNode.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGRouterMapperNode.h"
#import <pthread/pthread.h>
#import <YYModel/YYModel.h>
#import "BGRouterErrorHelper.h"

@interface BGRouterMapperNode()
{
    pthread_rwlock_t _lock_bgRWLock; ///< 读写锁
}
@property (nonatomic, copy) NSString *nodeFlag; ///< 节点标识
@property (nonatomic, copy) NSString *url; ///< url
@property (nonatomic, copy) NSString *urlParttern; ///< urlParttern
@property (nonatomic, strong) NSMutableDictionary<NSString *, BGRouterMapperNode *> *subNodeMap; ///< 下级节点
@property (nonatomic, assign) BOOL urlDeregistedFlag; ///< 节点取消注册的标识

@property(nonatomic, copy) BGRouterUrlExecuteAction executeAction; ///< url执行事件

@end

@implementation BGRouterMapperNode

- (instancetype)init {
    if (self = [super init]) {
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        self->_lock_bgRWLock = lock;
    }
    return self;
}

- (BOOL)bgInsertOneNodeWithUrl:(NSString *)url executeAction:(BGRouterUrlExecuteAction)executeAction error:(NSError **)err{
    BGRouterURLParameter *parser = [BGRouterURLParameter bgParserUrl:url parameter:nil];
    NSArray<NSString *> *url_parts = [parser bgUrlSeperateResult];
    
    pthread_rwlock_wrlock(&(self->_lock_bgRWLock)); /// 写加锁
    __block BGRouterMapperNode *lastNode = self;
    [url_parts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![lastNode.subNodeMap objectForKey:obj]) {
            BGRouterMapperNode *new = [BGRouterMapperNode new];
            new.nodeFlag = obj;
            [lastNode.subNodeMap setObject:new forKey:obj];
        }
        lastNode = [lastNode.subNodeMap objectForKey:obj];
    }];
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 写解锁
    
    if (lastNode.executeAction) { //此节点已经注册
        if (lastNode.urlDeregistedFlag == NO) { //此节点已经被注册,且未被取消注册
            NSString *msg = [NSString stringWithFormat:@""
                             "重复注册URL sorce:%@\n"
                             "new:%@"
                             "", lastNode.url, url];
            NSAssert(0, msg);
            NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeUrlDuplicate info:nil message:msg];
            if (err) *err = errBack;
            return NO;
        }else{
            //此节点已经被取消注册,此处覆盖原来的响应
            lastNode.urlDeregistedFlag = YES;
        }
    }
    
    lastNode.urlParttern = parser.urlParttern;
    lastNode.url = url;
    lastNode.executeAction = executeAction;
    return YES;
}

- (BGRouterMapperNode *)bgFuzzySearchNodeWithUrl:(NSString *)url error:(NSError **)err {
    return [self bgSearchNodeWithUrl:url absoluteFlag:NO error:err];
}

- (BGRouterMapperNode *)bgAbsoluteSearchNodeWithUrl:(NSString *)url error:(NSError **)err {
    return [self bgSearchNodeWithUrl:url absoluteFlag:YES error:err];
}

- (void)bgDeregisteNode{
    pthread_rwlock_wrlock(&(self->_lock_bgRWLock)); /// 写加锁
    self.urlDeregistedFlag = YES;
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 写解锁
}

- (void)bgCleanNodes {
    pthread_rwlock_wrlock(&(self->_lock_bgRWLock)); /// 写加锁
    [self.subNodeMap removeAllObjects];
    self.urlParttern = nil;
    self.executeAction = nil;
    self.nodeFlag = nil;
    self.urlDeregistedFlag = NO;
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 写解锁
}

- (BOOL)isNodesEmpty {
    BOOL result = NO;
    
    pthread_rwlock_rdlock(&(self->_lock_bgRWLock)); ////读加锁
    if (self.nodeFlag.length == 0) {
        if (self.subNodeMap.count == 0) {
            result = YES;
        }else{
            result = NO;
        }
    }else{
        result = NO;
    }
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 读解锁
    return result;
}

- (NSString *)bgRouterMapperJsonString {return [self yy_modelToJSONString];}
- (NSDictionary *)bgRouterMapperDict {return  [self yy_modelToJSONObject];}

# pragma mark - work methods
- (BGRouterMapperNode *)bgSearchNodeWithUrl:(NSString *)url absoluteFlag:(BOOL)absolute error:(NSError **)err {
    pthread_rwlock_rdlock(&(self->_lock_bgRWLock)); ////读加锁
    
    BGRouterURLParameter *parser = [BGRouterURLParameter bgParserUrl:url parameter:nil];
    NSArray<NSString *> *url_parts = [parser bgUrlSeperateResult];
    
    __block BGRouterMapperNode *lastNode = self;
    __block BGRouterMapperNode *lastEnableNode = self; //模糊匹配只需要找到一个可用的节点就行
    NSString *obj = nil;
    int idx = 0;
    for (; idx < url_parts.count; idx ++) {
        obj = url_parts[idx];
        if ([lastNode.subNodeMap objectForKey:obj]) { //存在下一个节点
            lastNode = [lastNode.subNodeMap objectForKey:obj];
            if (lastNode.urlDeregistedFlag == NO) {
                lastEnableNode = lastNode;
            }
        } else {
            break;
        }
    }
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 读解锁
    
    if (absolute == NO){ //模糊匹配
        if(lastEnableNode.executeAction == nil){ //模糊匹配, 也不能完全打开所有url
            NSString *msg = [NSString stringWithFormat:@"can note find register url:%@", url];
            NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeNoUrl info:nil message:msg];
            if (err) *err = errBack;
            return nil;
        }else if (lastEnableNode.urlDeregistedFlag){ //节点被关闭
            NSString *msg = [NSString stringWithFormat:@"url parttern is closed:%@", lastNode.urlParttern];
            NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeUrlClosed info:nil message:msg];
            if (err) *err = errBack;
        }
        return lastEnableNode;
    }
    
    if (idx < url_parts.count || lastNode.executeAction == nil){ //精准匹配, 需要匹配到所有节点
        NSString *msg = [NSString stringWithFormat:@"can note find register url:%@", url];
        NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeNoUrl info:nil message:msg];
        if (err) *err = errBack;
        return nil;
    } else if (lastNode.urlDeregistedFlag){
        NSString *msg = [NSString stringWithFormat:@"url is closed:%@", lastNode.urlParttern];
        NSError *errBack = [BGRouterErrorHelper bg_createRouterError:BGRouterComponentErrorCodeTypeUrlClosed info:nil message:msg];
        if (err) *err = errBack;
        return nil;
    }
    
    return lastNode;
}

#pragma mark - setter & getter methos
- (NSMutableDictionary<NSString *,BGRouterMapperNode *> *)subNodeMap {
    pthread_rwlock_rdlock(&(self->_lock_bgRWLock)); ////读加锁
    if (!_subNodeMap) _subNodeMap = [NSMutableDictionary new];
    pthread_rwlock_unlock(&(self->_lock_bgRWLock)); /// 读解锁
    return _subNodeMap;
}

@end
