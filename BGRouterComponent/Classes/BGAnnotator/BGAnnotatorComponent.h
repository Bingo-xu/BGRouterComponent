//
//  BGAnnotatorTool.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/14.
//

#import <Foundation/Foundation.h>
#import "BGAnnotatorDataFunc.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGAnnotatorComponent : NSObject

/**mach_o注册的事件*/
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<BGAnnotatorDataFunc *> *> *annotationFuncsDict;

/**服务实例*/
@property (nonatomic, strong) id serviceInstance;
/**路由实例*/
@property (nonatomic, strong) id routerInstance;

@end

NS_ASSUME_NONNULL_END
