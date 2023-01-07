//
//  BGRouterMapperNode.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGRouterDefines.h"
#import "BGRouterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGRouterMapperNode : NSObject

@property (nonatomic, readonly) NSString *nodeFlag; ///< 节点标识
@property (nonatomic, readonly) NSString *url; ///< url
@property (nonatomic, readonly) NSString *urlParttern; ///< urlParttern
@property (nonatomic, readonly)BOOL urlDeregistedFlag; ///< 节点取消注册的标识
@property(nonatomic, readonly) BGRouterUrlExecuteAction executeAction; ///< url执行事件
@property (nonatomic, readonly) BOOL isNodesEmpty; ///< 路由是否为空

- (BOOL)ykInsertOneNodeWithUrl:(NSString *)url executeAction:(BGRouterUrlExecuteAction)executeAction error:(NSError **)err;
- (BGRouterMapperNode *)bgSearchNodeWithUrl:(NSString *)url absoluteFlag:(BOOL)absolute error:(NSError **)err;
- (void)bgDeregisteNode;
- (void)bgCleanNodes;

# pragma mark - debug methods
- (NSString *)bgRouterMapperJsonString;
- (NSDictionary *)bgRouterMapperDict;

@end

NS_ASSUME_NONNULL_END
