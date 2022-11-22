//
//  DVEBundleLoader.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "DVEBundleLoader.h"
#import "NSDictionary+DVE.h"
#import "NSString+VEIEPath.h"
#import "NSString+VEToImage.h"
#import "DVEVCContext.h"
#import "DVELoggerImpl.h"
#import "DVEResourceMusicModelProtocol.h"

#import <YYModel/NSObject+YYModel.h>

NS_INLINE id<DVEResourceLoaderProtocol> DVEResourceLoader(DVEVCContext *vcContext) {
    return DVEOptionalInline(vcContext.serviceProvider, DVEResourceLoaderProtocol);
}

@implementation DVEBundleLoader

+ (instancetype)shareManager {
    static DVEBundleLoader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self shareManager];
}
-(id)copyWithZone:(NSZone *)zone{
    return [[self class] shareManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [[self class] shareManager];
}


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void)runInGlobalThread:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

- (void)canvasRatio:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander {
    if (hander) {
        if (!context || ![DVEResourceLoader(context) respondsToSelector:@selector(canvasRatioModel:)]) {
            hander(nil, nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) canvasRatioModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)adjust:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(adjustModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) adjustModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)animationIn:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(animationInModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) animationInModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}
- (void)animationOut:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(animationOutModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) animationOutModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}
- (void)animationCombin:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander;
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(animationCombinModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) animationCombinModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}


- (void)filter:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(filterModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) filterModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)musicCategory:(DVEVCContext*)context handler:(DVEModuleCategoryHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(musicCategory:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) musicCategory:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable categorys, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceCategoryModelProtocol> model in categorys) {
                        DVEEffectCategory *value = [DVEEffectCategory new];
                        value.name = model.name;
                        value.models = model.models;
                        value.categoryId = model.categoryId;
                        value.order = model.order;
                        [array addObject:value];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}

- (void)soundCategory:(DVEVCContext*)context handler:(DVEModuleCategoryHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(musicCategory:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) soundCategory:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable categorys, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceCategoryModelProtocol> model in categorys) {
                        DVEEffectCategory *value = [DVEEffectCategory new];
                        value.name = model.name;
                        value.models = model.models;
                        value.categoryId = model.categoryId;
                        value.order = model.order;
                        [array addObject:value];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}

- (void)sticker:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(stickerModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) stickerModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}

- (void)textAlign:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textAlignModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textAlignModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}
- (void)textFont:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textFontModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textFontModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}
- (void)textColor:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textColorModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textColorModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}
- (void)textStyle:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textStyleModel:)]){
            hander(@[],@"");
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textStyleModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}

- (void)transition:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander;
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(transitionModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) transitionModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}

- (void)mask:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander;
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(maskModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) maskModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)audioChange:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(maskModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) audioChangModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)duet:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander;
{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(duetModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) duetModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceModelProtocol> model in datas) {
                        DVEEffectValue *eValue = [[DVEEffectValue alloc] initWithInjectModel:model];
                        eValue.key = @"switchButton";
                        eValue.indesty = 1;
                        [array addObject:eValue];
                    }
                }
                hander(array,errMsg);
            }];
        }];
    }
}


- (void)effectCategory:(DVEVCContext *)context handler:(DVEModuleCategoryHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(effectCategory:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) effectCategory:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable categorys, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceCategoryModelProtocol> model in categorys) {
                        DVEEffectCategory *value = [DVEEffectCategory new];
                        value.name = model.name;
                        value.models = model.models;
                        value.categoryId = model.categoryId;
                        value.order = model.order;
                        [array addObject:value];
                    }
                }
                hander(array,errMsg);
            }];

        }];
    }
}

- (void)effect:(DVEVCContext *)context category:(DVEEffectCategory*)category handler:(DVEModuleModelHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(effectModel:handler:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) effectModel:category handler:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)textTemplateCategory:(DVEVCContext *)context handler:(DVEModuleCategoryHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(effectCategory:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textTemplateCategory:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable categorys, NSString * _Nullable errMsg) {
                NSMutableArray *array = nil;
                if(!errMsg){
                    array = [NSMutableArray array];
                    for (id<DVEResourceCategoryModelProtocol> model in categorys) {
                        DVEEffectCategory *value = [DVEEffectCategory new];
                        value.name = model.name;
                        value.models = model.models;
                        value.categoryId = model.categoryId;
                        value.order = model.order;
                        [array addObject:value];
                    }
                }
                hander(array,errMsg);
            }];

        }];
    }
}

- (void)textTemplate:(DVEVCContext *)context category:(DVEEffectCategory*)category handler:(DVEModuleModelHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(effectModel:handler:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textTemplateModel:category handler:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)flowerText:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander {
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(flowerTextModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) flowerTextModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)textAnimation:(DVEVCContext*)context type:(DVEAnimationType)type handler:(DVEModuleModelHandler)hander {
    if (!hander) {
        return;
    }
    
    if (!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textAnimationModel:type:)]) {
        hander(nil,nil);
        return;
    }
    
    [self runInGlobalThread:^{
        [DVEResourceLoader(context) textAnimationModel:[DVEBundleLoader commonLoadHandler:hander] type:type];
    }];
}

- (void)stickerAnimation:(DVEVCContext *)context type:(DVEAnimationType)type handler:(DVEModuleModelHandler)hander
{
    if (!hander) {
        return;
    }
    
    if (!context || ![DVEResourceLoader(context) respondsToSelector:@selector(stickerAnimationModel:type:)]) {
        hander(nil,nil);
        return;
    }
    
    [self runInGlobalThread:^{
        [DVEResourceLoader(context) stickerAnimationModel:[DVEBundleLoader commonLoadHandler:hander] type:type];
    }];
}

- (void)mixedEffect:(DVEVCContext *)context handler:(DVEModuleModelHandler)hander{
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(mixedEffectModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) mixedEffectModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}

- (void)textReaderSoundEffectList:(DVEVCContext*)context
                          handler:(DVEModuleTextReaderModelHandler)handler
{
#if ENABLE_SUBTITLERECOGNIZE
    if(handler){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(textReaderSoundEffectModel:)]){
            handler(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textReaderSoundEffectModel:handler];
        }];
    }
#endif
}

- (void)canvasStyleEffectList:(DVEVCContext *)context
                      handler:(DVEModuleModelHandler)handler {
    if (handler) {
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(canvasStyleResourceModel:)]){
            handler(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) canvasStyleResourceModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
                if (errMsg) {
                    !handler ?: handler(nil, errMsg);
                    return;
                }
                
                NSArray<id<DVEResourceModelProtocol>> *models = [datas firstObject].models;
                NSMutableArray *array = [NSMutableArray array];
                for (id<DVEResourceModelProtocol> model in models) {
                    [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
                }
                !handler ?: handler(array, nil);
            }];
        }];
    }
}

- (void)curveSpeed:(DVEVCContext *)context handler:(DVEModuleCurveSpeedModelHandler)handler {
    if (handler) {
        if (!context || ![DVEResourceLoader(context) respondsToSelector:@selector(curveSpeedResourceModel:)]) {
            handler(nil, nil);
            return;
        }
    }
    [self runInGlobalThread:^{
        [DVEResourceLoader(context) curveSpeedResourceModel:handler];
    }];
}

- (void)textBubble:(DVEVCContext*)context handler:(DVEModuleModelHandler)hander {
    if(hander){
        if(!context || ![DVEResourceLoader(context) respondsToSelector:@selector(flowerTextModel:)]){
            hander(nil,nil);
            return;
        }
        [self runInGlobalThread:^{
            [DVEResourceLoader(context) textBubbleModel:[DVEBundleLoader commonLoadHandler:hander]];
        }];
    }
}


+(DVEResourceModelLoadHandler)commonLoadHandler:(DVEModuleModelHandler)hander{
    return ^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
        NSMutableArray *array = nil;
        if(!errMsg){
            array = [NSMutableArray array];
            for (id<DVEResourceModelProtocol> model in datas) {
                [array addObject:[[DVEEffectValue alloc] initWithInjectModel:model]];
            }
        }
        hander(array,errMsg);
    };
}

@end
