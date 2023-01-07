//
//  BGAnnotatorDefineHeader.h
//  Pods
//
//  Created by Bingo on 2022/12/14.
//

#ifndef BGAnnotatorDefineHeader_h
#define BGAnnotatorDefineHeader_h

#endif /* BGAnnotatorDefineHeader_h */

#if defined(__cplusplus)
extern "C" {
#endif

typedef void(*BGAnnotatorMach_O_Method)(void);

struct BGAnnotatorRegisterStruct{
    char *sectionFlag; ///< 字符, 用以存放mach_o字段标识,用于在读取的时候判定是否是合法的struct.
    char *typeFlag; ///<  字符,用以存放SEL功能标识,长度不限制,用于标识SEL的功能类型.
    char *externStr; ///< 扩展信息, 为了便于以后扩展, 注意是字符串类型
    BGAnnotatorMach_O_Method executeMethod; ///< 注册的SEL
};


#ifndef BGAnnotatorSection_SEL
#define BGAnnotatorSection_SEL     "BGANOTATOR_SEL"
#endif


#define bg_merge(a, b) a ## b //合并用的主体
#define _BGA_UNIQUE_ID(func)  bg_merge(func, merge(_unused, __COUNTER__))

/**
 注册事件
 */
#define _BG_ANOTATOR_REGISTER_FUNC_(funcType, externStr, funcName) \
\
static void funcName (void); \
\
/**使用 used字段，即使没有任何引用，在Release下也不会被优化 __attribute__((used, section("__DATA," "BGANOTATOR_SEL")))*/  \
__attribute__((used, section("__DATA," BGAnnotatorSection_SEL))) static const struct BGAnnotatorRegisterStruct merge(BGAnnStruct_, funcName) = (struct BGAnnotatorRegisterStruct){ \
(char *) BGAnnotatorSection_SEL, \
(char *) funcType, \
(char *) externStr, \
(BGAnnotatorMach_O_Method) funcName, \
};\
\
static void funcName(void)

/**
 向mach_o 注册方法
 */
#define BGAnnotatorRegisterSEL(funcType, externStr)  _BG_ANOTATOR_REGISTER_FUNC_(funcType, externStr, _BGA_UNIQUE_ID(BGAN_register_func_))

#if defined(__cplusplus)
}
#endif



