//
//  BGRouterParameter.h
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import <Foundation/Foundation.h>
#import "BGRouterDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;
@interface BGRouterUrlRequest : NSObject<NSCopying>

@property(nonatomic, copy) NSString * url; ///< url
@property (nonatomic,assign) BOOL absolute; ///< 绝对匹配URL
@property(nonatomic, copy) NSString * urlParttern; ///< urlParttern
@property(nonatomic, weak) UIViewController * fromVC; ///< 跳转的来源页面
@property(nonatomic, assign) BGRouterAnimationType animateTyepe; ///< 界面切换类型
@property(nonatomic, copy) NSDictionary * parameter; ///< 序列化后的参数
@property(nonatomic, copy) NSDictionary * paraOrignal; ///< 原始参数

+ (instancetype)instanceWithBuilder:(void(^)(BGRouterUrlRequest *builder))builderAction;

@end

@interface BGRouterUrlResponse : NSObject<NSCopying>

@property (nonatomic,assign) NSInteger status; ///< 业务码
@property (nonatomic, strong) NSDictionary * __nullable responseObj; ///< 应答数据
@property(nonatomic, copy) NSString * msg; ///< 业务应当信息
@property (nonatomic, strong) NSError * __nullable err; ///< 业务错误对象

+ (instancetype)instanceWithBuilder:(void(^)(BGRouterUrlResponse *response))builderAction;

@end


@interface BGRouterURLParameter : NSObject<NSCopying>

@property (nonatomic,readonly) NSString *url;  ///< url
@property (nonatomic,readonly) NSDictionary<NSString *, NSString*> *queryparamaters;  ///< query parameters
@property (nonatomic,readonly) NSString *fragment;  ///< fragment
@property (nonatomic,readonly) NSString *urlParttern;  ///< urlParttern
@property (nonatomic,readonly) NSString *urlPartternFull;  ///< urlParttern full

+ (instancetype)bgParserUrl:(NSString *)url parameter:(NSDictionary * __nullable)parameter;

- (NSArray<NSString *> *)bgUrlSeperateResult;

@end

NS_ASSUME_NONNULL_END
