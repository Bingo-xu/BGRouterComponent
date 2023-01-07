//
//  BGAnnotatorDataFunc.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/14.
//

#import <Foundation/Foundation.h>
#import "BGAnnotatorDefineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGAnnotatorDataFunc : NSObject

/**执行函数**/
@property (nonatomic,readonly) BGAnnotatorMach_O_Method bgMacho_O_method;

/**事件类型标识**/
@property (nonatomic,readonly) NSString *bgTypeFlag;


+ (instancetype)bg_instanceWithFuncInfo:(struct BGAnnotatorRegisterStruct)info;

@end

NS_ASSUME_NONNULL_END
