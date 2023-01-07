//
//  BGRouterErrorHelper.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGRouterErrorHelper.h"
#import "BGRouterDefines.h"

@implementation BGRouterErrorHelper

/**路由错误日志*/
+ (NSError *)bg_createRouterError:(NSInteger)code info:(NSDictionary *__nullable)info message:(NSString *)msg {
    NSMutableDictionary *errInfo =
    [NSMutableDictionary dictionaryWithDictionary:
     @{
        NSLocalizedDescriptionKey: msg.length ? msg : BGRouterError_Unknow,
        NSLocalizedFailureReasonErrorKey : msg.length ? msg : BGRouterError_Unknow,
        BGRouterError_DescriptionKey : msg.length ? msg : BGRouterError_Unknow,
    }];
    
    [errInfo addEntriesFromDictionary:info];
    NSError *error = [NSError errorWithDomain:BGRouterError_Domain code:code userInfo:errInfo];
    NSLog(@"BGRouter work unnormal:%@", msg);
    return error;
}

@end
