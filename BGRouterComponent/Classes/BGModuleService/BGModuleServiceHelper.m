//
//  BGModuleServiceHelper.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGModuleServiceHelper.h"
#import "BGModuleServiceHeader.h"

@implementation BGModuleServiceHelper

+ (NSError *)bg_createServiceError:(NSInteger)code info:(NSDictionary *)info message:(NSString *)msg {
    NSMutableDictionary *errInfo =
    [NSMutableDictionary dictionaryWithDictionary:
     @{
        NSLocalizedDescriptionKey: msg.length ? msg : BGModuleError_Unknow,
        NSLocalizedFailureReasonErrorKey : msg.length ? msg : BGModuleError_Unknow,
        BGModuleError_DescriptionKey : msg.length ? msg : BGModuleError_Unknow,
    }];
    [errInfo addEntriesFromDictionary:info];
    NSError *error = [NSError errorWithDomain:BGModuleError_Domain code:code userInfo:errInfo];
    return error;
}

@end
