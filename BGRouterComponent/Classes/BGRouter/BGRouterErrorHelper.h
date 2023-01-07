//
//  BGRouterErrorHelper.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGRouterErrorHelper : NSObject

/**路由错误日志*/
+ (NSError *)bg_createRouterError:(NSInteger)code info:(NSDictionary *__nullable)info message:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
