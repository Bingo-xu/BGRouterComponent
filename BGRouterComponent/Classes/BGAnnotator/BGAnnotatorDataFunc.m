//
//  BGAnnotatorDataFunc.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/14.
//

#import "BGAnnotatorDataFunc.h"

@interface BGAnnotatorDataFunc ()

/**事件信息*/
@property (nonatomic,assign) struct BGAnnotatorRegisterStruct bg_funcInfo;

@end

@implementation BGAnnotatorDataFunc

+ (instancetype)bg_instanceWithFuncInfo:(struct BGAnnotatorRegisterStruct)info {
    BGAnnotatorDataFunc *result = [[self alloc]init];
    struct BGAnnotatorRegisterStruct func = (struct BGAnnotatorRegisterStruct){NULL, NULL};
    memcpy(&func, &info, sizeof(struct BGAnnotatorRegisterStruct));
    result.bg_funcInfo = func;
    return result;
}

- (NSString *)bgTypeFlag {
    return self.bg_funcInfo.typeFlag ? [[NSString alloc] initWithCString:self.bg_funcInfo.typeFlag encoding:NSUTF8StringEncoding] : nil;
}

- (BGAnnotatorMach_O_Method)ykMacho_O_method {
    return self.bg_funcInfo.executeMethod;
}

@end
