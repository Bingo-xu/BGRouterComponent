//
//  BGRouterMessageBody.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGRouterProtocol.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BGRouterEventIdType) {
    BGRouterEventIdTypeUnknown = 0,
    BGRouterEventIdTypeRegisterUrl,
    BGRouterEventIdTypeDeregisterUrl,
    BGRouterEventIdTypeOpenUrl,
    BGRouterEventIdTypeCheckUrl,
};

@interface BGRouterMessageBody : NSObject <BGRouterMessageBodyProtocol>

@property (nonatomic,assign) BGRouterEventIdType eventIdentifier; ///< 事件数字表示


- (void)setEventMessage:(NSString *)eventMessage;

@end

NS_ASSUME_NONNULL_END
