//
//  BGRouterDefines.h
//  Pods
//
//  Created by Bingo on 2022/12/15.
//

typedef NS_ENUM(NSInteger, BGRouterComponentErrorCodeType) {
    BGRouterComponentErrorCodeTypeSuccess = 0, /// < 业务成功
    BGRouterComponentErrorCodeTypeNoUrl = -1, /// < URL未注册
    BGRouterComponentErrorCodeTypeUrlClosed = -2, /// < URL关闭
    BGRouterComponentErrorCodeTypeUrlDuplicate = -3, /// < 重复注册URL
};

typedef NS_ENUM(NSInteger, BGRouterAnimationType) {
    BGRouterAnimationTypePush = 0, /// < 压栈切换界面
    BGRouterAnimationTypePresent, /// < 模态切换界面
};


static NSErrorDomain const BGRouterError_Domain = @"BGRouterError_Domain";
static NSErrorUserInfoKey const BGRouterError_DescriptionKey = @"BGRouterError_DescriptionKey";
static NSErrorUserInfoKey const BGRouterError_Unknow = @"BGRouterError_Unknow";

static NSString const *BGRouterWildcardDomain = @"BGRouterWildcardDomain://wildcard_bg_router";


#define BGRouterComponentFlag "BGRouterComponentFlag"
/**
 注册路由
 
 code example:
 
 //@implementation YourClass
 @BGRouterRegister(){
 NSLog(@"register_Router");
 // Your code.
 }
 //@end
 
 */
#define BGRouterRegister() BGAnnotatorRegisterSEL(BGRouterComponentFlag, "router_future")
