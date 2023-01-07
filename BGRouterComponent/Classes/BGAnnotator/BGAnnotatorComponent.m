//
//  BGAnnotatorTool.m
//  BGRouterComponent
//
//  Created by Bingo on 2022/12/14.
//

#import "BGAnnotatorComponent.h"
#include <mach-o/getsect.h>
#include <mach-o/dyld.h>

@interface BGAnnotatorComponent()<NSCopying, NSMutableCopying>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<BGAnnotatorDataFunc *> *> *annotatorFuncsDict_pri; ///< mach_o注册的事件
@end

@implementation BGAnnotatorComponent

- (NSDictionary<NSString *,NSArray<BGAnnotatorDataFunc *> *> *)annotationFuncsDict {
    return self.annotatorFuncsDict_pri.count ? [NSDictionary dictionaryWithDictionary:self.annotatorFuncsDict_pri] : nil;
}

static BGAnnotatorComponent *imp;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imp = [[super allocWithZone:zone] init_annotatorComponent];
    });
    return imp;
}

- (instancetype)init {return imp;}
- (id)copyWithZone:(NSZone *)zone {return imp;}
- (id)mutableCopyWithZone:(NSZone *)zone {return imp;}

- (instancetype)init_annotatorComponent {
    if (self = [super init]) {
        self.annotatorFuncsDict_pri = [NSMutableDictionary new];
    }
    return self;
}

@end



NSArray<NSString *>* BGReadConfiguration(char *sectionName,const struct mach_header *mhp);
NSMutableArray<BGAnnotatorDataFunc *>* BGReadMach_oFunctions(char *sectionName,const struct mach_header *mhp);

static void bg_dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    //macho_o section SEL
    NSArray<BGAnnotatorDataFunc *> *funsArr = BGReadMach_oFunctions(BGAnnotatorSection_SEL, mhp);
    NSMutableDictionary *dict = [BGAnnotatorComponent new].annotatorFuncsDict_pri;
    [funsArr enumerateObjectsUsingBlock:^(BGAnnotatorDataFunc * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.bgTypeFlag.length) return;
        
        NSMutableArray *arr = [dict objectForKey:obj.bgTypeFlag];
        if (!arr) {
            arr = [NSMutableArray new];
            [dict setObject:arr forKey:obj.bgTypeFlag];
        }
        [arr addObject:obj];
    }];
}

/**
 当一个函数被__attribute__((constructor))修饰时，表示这个函数是这个image的初始化函数，在image被加载时，首先会调用这个函数。（image指的是mach-o和动态共享库，在工程运行时，可以使用lldb命令image list查看这个工程中加载的所有image。）
 上述代码表示initProphet函数被指定为mach-o的初始化函数，当dyld（动态链接器）加载mach-o时，执行initProphet函数，其执行时机在main函数和类的load方法之前。
 当_dyld_register_func_for_add_image(dyld_callback);被执行时，如果已经加载了image，则每存在一个已经加载的image就执行一次dyld_callback函数，在此之后，每当有一个新的image被加载时，也会执行一次dyld_callback函数。
 （dyld_callback函数在image的初始化函数之前被调用，mach-o是第一个被加载的image，调用顺序是：load mach-o -> initProphet -> dyld_callback -> load other_image -> dyld_callback -> other_image_initializers  -> ......）

 */
__attribute__((constructor))
void bg_initProphet(void) {
    _dyld_register_func_for_add_image(bg_dyld_callback);
}

NSMutableArray<BGAnnotatorDataFunc *>* BGReadMach_oFunctions(char *sectionName,const struct mach_header *mhp){
    NSMutableArray<BGAnnotatorDataFunc *> *result = [NSMutableArray new];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    unsigned char *memory = (unsigned char *)(uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    if (size != 0) {
        NSLog(@"found function section: %s", sectionName);
    }
    
    unsigned long perSize = sizeof(struct BGAnnotatorRegisterStruct);
    for(int offset = 0; offset < size; ){
        struct BGAnnotatorRegisterStruct *point = (struct BGAnnotatorRegisterStruct*)(memory + offset);
        struct BGAnnotatorRegisterStruct onfInfo;
        memcpy(&onfInfo, point, perSize);
        if (onfInfo.sectionFlag && strcmp(onfInfo.sectionFlag, sectionName) == 0) {
            [result addObject:[BGAnnotatorDataFunc bg_instanceWithFuncInfo:onfInfo]];
        }
        offset += perSize;
    }
    return result;
}

