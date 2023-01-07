//
//  BGRouterMessageBody.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGRouterMessageBody.h"

@interface BGRouterMessageBody()

@property(nonatomic, copy) NSString * eventName; ///< 事件名称
@property(nonatomic, copy) NSString * eventMessage; ///< 事件信息

@end

@implementation BGRouterMessageBody

- (void)setEventIdentifier:(BGRouterEventIdType)eventIdentifier {
    _eventIdentifier = eventIdentifier;
    _eventName = [self bg_RouterEventNameWithID:eventIdentifier];
}

- (NSString *)bg_RouterEventNameWithID:(BGRouterEventIdType)enentID {
    NSString *result = nil;
    switch (enentID) {
        case BGRouterEventIdTypeRegisterUrl:
            result = @"BGRouterEventIdTypeRegisterUrl";
            break;
        case BGRouterEventIdTypeDeregisterUrl:
            result = @"BGRouterEventIdTypeDeregisterUrl";
            break;
        case BGRouterEventIdTypeOpenUrl:
            result = @"BGRouterEventIdTypeOpenUrl";
            break;
        case BGRouterEventIdTypeCheckUrl:
            result = @"BGRouterEventIdTypeCheckUrl";
            break;
        default:
            result = @"BGRouterEventIdTypeUnknown";
            break;
    }
    return result;
}

@end
