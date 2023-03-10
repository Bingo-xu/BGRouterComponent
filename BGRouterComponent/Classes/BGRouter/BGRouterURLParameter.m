//
//  BGRouterParameter.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/15.
//

#import "BGRouterURLParameter.h"
#import <YYModel/YYModel.h>

@implementation BGRouterUrlRequest

+ (instancetype)instanceWithBuilder:(void (^)(BGRouterUrlRequest *builder))builderAction {
    if (!builderAction) return nil;
    BGRouterUrlRequest *result = [[[self class] alloc] init];
    builderAction(result);
    return [result copy];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end

@implementation BGRouterUrlResponse

+ (instancetype)instanceWithBuilder:(void (^)(BGRouterUrlResponse *response))builderAction {
    BGRouterUrlResponse *result = [[[self class] alloc] init];
    builderAction(result);
    return [result copy];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end


@interface BGRouterURLParameter ()

@property (nonatomic,copy) NSString *url;  ///< url
@property (nonatomic,copy) NSString *scheme;  ///< scheme
@property (nonatomic,copy) NSString *host;  ///< host
@property (nonatomic,strong) NSNumber *port;  ///< port
@property (nonatomic,copy) NSString *path;  ///< path
@property (nonatomic,copy) NSArray<NSString *> *pathComponents;  ///< path components
@property (nonatomic,copy) NSString *userName;  ///< user name
@property (nonatomic,copy) NSString *passWord;  ///< pass word
@property (nonatomic,copy) NSString *query;  ///< query
@property (nonatomic,copy) NSDictionary<NSString *, NSString*> *queryparamaters;  ///< query parameters
@property (nonatomic,copy) NSString *fragment;  ///< fragment
@property (nonatomic,copy) NSString *urlParttern;  ///< urlParttern
@property (nonatomic,copy) NSString *urlPartternFull;  ///< urlParttern full

@end

@implementation BGRouterURLParameter

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

+ (instancetype)bgParserUrl:(NSString *)url parameter:(NSDictionary *)parameter {
    if(!url.length) return nil;
    BGRouterURLParameter *parser = [self new];
    [parser bg_parserUrl:url parameter:parameter];
    return parser;
}

- (NSArray<NSString *> *)bgUrlSeperateResult {
    NSMutableArray<NSString *> *url_parts = [NSMutableArray new];
    [url_parts addObject:self.scheme];
    self.host ? [url_parts addObject:self.host] : 0;
    self.port ? [url_parts addObject:[NSString stringWithFormat:@"%@", self.port]] : 0;
    [url_parts addObjectsFromArray:self.pathComponents];
    return [NSArray arrayWithArray: url_parts];
}

- (void)bg_parserUrl:(NSString *)url parameter:(NSDictionary *)parameter {
    /**
     ??????????????????????????????scheme,
          ??????????????? ????????????host
         ???????????????  ????????????port
     path ???????????? ??????, ??????????????????????????????, ??????????????????????????????????????????.
     openUrl????????????????????? ??????????????? ????????????.
     
     scheme ??????, ???????????????host
            port ???????????????
     path ???????????????
     query
     fragment
     */
    /**
     ????????????????????????
     */
    url = [url stringByRemovingPercentEncoding];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLComponents *component = [NSURLComponents componentsWithString:url];
    NSString *scheme = @"bgrouter";
    if (component.scheme.length == 0) { //??????scheme,??????scheme?????????.
        /**
         1.????????????scheme[://], ???????????????.
         2. ??????????????????scheme??????,???URL???????????????????????????
         */
        NSString *url_extern = url;
        if ([url rangeOfString:@"://"].location != NSNotFound) {
            scheme = [url componentsSeparatedByString:@"://"].firstObject;
            url_extern = [[url componentsSeparatedByString:@"://"] lastObject];
        }
        
        NSString const * wildcardScheme = @"bgrouter://";
        url_extern = [wildcardScheme stringByAppendingString:url_extern];
        component = [NSURLComponents componentsWithString:url_extern];
    }else{
        scheme = component.scheme;
    }
    
    self.url = url;
    self.scheme = scheme;

    component.user.length ? self.userName = component.user : 0;
    component.password.length ? self.passWord = component.password : 0;
    component.host.length ? self.host = component.host : 0;
    component.port ? self.port = component.port : 0;
    
    if (component.path.length){
        NSMutableArray *arr = [NSMutableArray new];
        [[component.path pathComponents] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqualToString:@"/"]) [arr addObject:obj];
        }];
        
        self.path = component.path;
        self.pathComponents = [NSArray arrayWithArray:arr];
    }
    
    NSMutableDictionary *queryDict = [NSMutableDictionary new];
    [component.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [queryDict setObject:obj.value forKey:obj.name];
    }];
    queryDict.count ? self.queryparamaters = queryDict : 0;
    
    component.fragment.length ? self.fragment = component.fragment : nil;
    
    NSString *lastPath = [self bgUrlSeperateResult].lastObject;
    self.urlParttern = [[self filterUrlPartternWithUrl:url lastPath:lastPath] stringByRemovingPercentEncoding];
    self.urlPartternFull = [self filterUrlPartternWithUrl:[component.URL absoluteString] lastPath:lastPath];
//    NSLog(@"url info:%@", [self yy_modelDescription]);
}

- (NSString *)filterUrlPartternWithUrl:(NSString *)url lastPath:(NSString *)lastPath {
    NSRange pathRan = [url rangeOfString:lastPath];
    NSString *parttern = [url substringToIndex:pathRan.location + pathRan.length];
    return parttern;
}

@end
