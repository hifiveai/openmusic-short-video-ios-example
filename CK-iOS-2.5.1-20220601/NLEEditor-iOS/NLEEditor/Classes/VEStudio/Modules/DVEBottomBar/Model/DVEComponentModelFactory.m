//
//   DVEComponentModelFactory.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/3.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//


#import "DVEComponentModelFactory.h"
#import "DVEBarComponentModel.h"
#import "DVEComponentAction.h"
#import "NSString+VEToImage.h"

static NSString * const kTypeKey = @"type";
static NSString * const kImageKey = @"image";
static NSString * const kTitleKey = @"title";
static NSString * const kActionKey = @"action";
static NSString * const kStatusKey = @"status";
static NSString * const kUrlKey = @"url";
static NSString * const kGroupKey = @"group";

@implementation DVEComponentModelFactory

#pragma mark - Component

+ (id<DVEBarComponentProtocol>)createComponentWithType:(DVEBarComponentType)type
                                            actionName:(NSString*)actionName parent:(id<DVEBarComponentProtocol>)parent
                                    createSubComponent:(BOOL)create
{
    return [DVEComponentModelFactory createComponentWithType:type viewModel:nil actionName:actionName  parent:parent createSubComponent:create];
}

+ (id<DVEBarComponentProtocol>)createComponentWithType:(DVEBarComponentType)type
                                             viewModel:(id<DVEBarComponentViewModelProtocol>)viewModel
                                                parent:(id<DVEBarComponentProtocol>)parent
                                    createSubComponent:(BOOL)create
{
    return [DVEComponentModelFactory createComponentWithType:type viewModel:nil actionName:nil parent:parent createSubComponent:create];
}

+ (id<DVEBarComponentProtocol>)createComponentWithType:(DVEBarComponentType)type
                                                parent:(id<DVEBarComponentProtocol>)parent
                                    createSubComponent:(BOOL)create
{
    return [DVEComponentModelFactory createComponentWithType:type viewModel:nil actionName:nil parent:parent createSubComponent:create];
}

+ (id<DVEBarComponentProtocol>)createComponentWithType:(DVEBarComponentType)type
                                             viewModel:(id<DVEBarComponentViewModelProtocol>)viewModel
                                            actionName:(NSString*)actionName
                                                parent:(id<DVEBarComponentProtocol>)parent
                                    createSubComponent:(BOOL)create
{
    DVEBarComponentModel *model = nil;
    switch(type)
    {
        case DVEBarComponentTypeRoot: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:nil title:nil actionName:NSStringFromSelector(@selector(openSubComponent:)) parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultRootSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeBlendCut: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_cut" title:NLELocalizedString(@"ck_edit_clip",@"剪辑") actionName:@"blendCutComponentOpen:" parent:parent];
            ///为了区分副轨道点击展示的剪辑菜单，这里使用一个隐藏虚假节点
            ///当点击副轨道视频，触发该节点类型的action
            ///并且构建一个无用子节点
            model.subComponents = @[
                [self createComponentModelWithType:type viewModel:nil actionName:nil parent:model]
            ];
        } break;
        case DVEBarComponentTypeCut: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_cut" title:NLELocalizedString(@"ck_edit_clip",@"剪辑") actionName:@"cutComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultCutSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeCanvas: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_canvas" title:NLELocalizedString(@"ck_size",@"尺寸") actionName:@"openCanvas:" parent:parent];
        } break;
        case DVEBarComponentTypeAudio: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_audio" title:NLELocalizedString(@"ck_audio",@"音频") actionName:@"audioComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultAudioSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeSticker: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_sticker" title:NLELocalizedString(@"ck_image_sticker",@"贴纸") actionName:@"stickerComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultStickerSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeText: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_text" title:NLELocalizedString(@"ck_text",@"文本") actionName:@"textComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultTextSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeFilterPartly:
        case DVEBarComponentTypeFilterGobal: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_filter" title:NLELocalizedString(@"ck_filter",@"滤镜") actionName:@"filterComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultFilterSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeRegulate: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_tiaojie" title:NLELocalizedString(@"ck_adjust",@"调节") actionName:@"regulateComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultRegulateSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypePicInPic: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_hzh" title:NLELocalizedString(@"ck_pip",@"画中画") actionName:@"picInpicComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultPicInPicSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeEffect: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_add_effect" title:NLELocalizedString(@"ck_effect",@"特效") actionName:@"effectComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultEffectSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeEffectSubObject: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_effects_object" title:NLELocalizedString(@"ck_applied_range",@"作用对象") actionName:@"objectEffect:" parent:parent];
        } break;
        case DVEBarComponentTypeEffectSubReplace: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_add_effect" title:NLELocalizedString(@"ck_replace_effect",@"替换特效") actionName:@"replaceEffect:" parent:parent];
        } break;
        case DVEBarComponentTypeSplit: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_chaifen" title:NLELocalizedString(@"ck_split",@"拆分") actionName:@"openSplit:" parent:parent];
        } break;
        case DVEBarComponentTypeSpeed: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_sudu" title:NLELocalizedString(@"ck_speed",@"速度") actionName:NSStringFromSelector(@selector(openSubComponent:)) parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultSpeedSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeCanvasBackground: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_canvasbackground" title:NLELocalizedString(@"ck_canvas",@"画布") actionName:@"canvasBackgroundComponentOpen:" parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultCanvasBackgroundSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeSound: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_sound" title:NLELocalizedString(@"ck_volume",@"音量") actionName:@"openSound:" parent:parent];
        } break;
        case DVEBarComponentTypeRotate: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_rotate" title:NLELocalizedString(@"ck_rotate",@"旋转") actionName:@"openRotate:" parent:parent];
        } break;
        case DVEBarComponentTypeFlip: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_fanzhuan" title:NLELocalizedString(@"ck_flip",@"翻转") actionName:@"openFlip:" parent:parent];
        } break;
        case DVEBarComponentTypeCrop: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_caijian" title:NLELocalizedString(@"ck_crop",@"裁剪") actionName:@"openCrop:" parent:parent];
        } break;
        case DVEBarComponentTypeReverse: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_daofang" title:NLELocalizedString(@"ck_reverse",@"倒放") actionName:@"openReverse:" parent:parent];
        } break;
        case DVEBarComponentTypeAnimation: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_donghua" title:NLELocalizedString(@"ck_text_anima",@"动画") actionName:NSStringFromSelector(@selector(openSubComponent:)) parent:parent];
            if (create) {
                model.subComponents = [DVEComponentModelFactory parseSubComponentConfig:[DVEComponentModelFactory defaultAnimationSubComponent] parent:model createSubComponent:create];
            }
        } break;
        case DVEBarComponentTypeFreeze: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_freeze" title:NLELocalizedString(@"ck_freeze",@"定格") actionName:@"cut_openFreeze:" parent:parent];
        } break;
        case DVEBarComponentTypeVideoCover: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:nil title:nil actionName:@"openVideoCover:" parent:parent];
        } break;
        case DVEBarComponentTypeAnimationIn: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevcanimation_admisson" title:NLELocalizedString(@"ck_anim_in",@"入场动画") actionName:@"openAnimationIn:" parent:parent];
        } break;
        case DVEBarComponentTypeAnimationOut: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevcanimation_disappear" title:NLELocalizedString(@"ck_anim_out",@"出场动画") actionName:@"openAnimationOut:" parent:parent];
        } break;
        case DVEBarComponentTypeAnimationCombine: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevcanimation_combination" title:NLELocalizedString(@"ck_animation_group",@"组合动画") actionName:@"openAnimationCombination:" parent:parent];
        } break;
        case DVEBarComponentTypeMask: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_cut_mask" title:NLELocalizedString(@"ck_video_mask",@"蒙版") actionName:@"openMask:" parent:parent];
        } break;
        case DVEBarComponentTypeMixedMode: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_cut_mix" title:NLELocalizedString(@"ck_mix_mode",@"混合模式") actionName:@"openMixedMode:" parent:parent];
        } break;
        case DVEBarComponentTypeBack: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_back_level_one" title:@"" actionName:[DVEComponentModelFactory componentBackActionName:parent] parent:parent];
        } break;
        case DVEBarComponentTypeBack2: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_back_level_two" title:@"" actionName:[DVEComponentModelFactory componentBackActionName:parent] parent:parent];
        } break;
        case DVEBarComponentTypeTextReader: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_vevc_text_reader" title:NLELocalizedString(@"",@"文本朗读") actionName:@"openTextReader:" parent:parent];
        } break;
        case DVEBarComponentTypeTransitionAnimation: {
            model = [DVEComponentModelFactory createComponentModelWithType:type imageName:@"icon_cutsub_donghua" title:NLELocalizedString(@"ck_transition",@"转场动画") actionName:@"openTransitionAnimation:slot:" parent:parent];
        } break;
        default: {
            model = [DVEComponentModelFactory createComponentModelWithType:type viewModel:viewModel actionName:actionName parent:parent];
        }
    }
    
    if (model) {
        if (actionName) {
            model.clickActionName = actionName;
        }
        if (viewModel) {
            model.viewModel = viewModel;
        }
    }
    return model;
}

#pragma mark - Model

+ (id<DVEBarComponentProtocol>)createComponentModelWithType:(DVEBarComponentType)type
                                                  imageName:(NSString *)imageName
                                                      title:(NSString *)title
                                                 actionName:(NSString *)actionName
                                                     parent:(id<DVEBarComponentProtocol>)parent
{
    DVEBarComponentViewModel *viewModel = nil;
    if (imageName || title) {
        viewModel = [[DVEBarComponentViewModel alloc] initWithImage:imageName.dve_toImage url:nil title:title];
    }

    return [DVEComponentModelFactory createComponentModelWithType:type viewModel:viewModel actionName:actionName parent:parent];
}

+ (id<DVEBarComponentProtocol>)createComponentModelWithType:(DVEBarComponentType)type
                                                  viewModel:(id<DVEBarComponentViewModelProtocol>)viewModel
                                                 actionName:(NSString *)actionName
                                                     parent:(id<DVEBarComponentProtocol>)parent
{
    DVEBarComponentModel *model = [[DVEBarComponentModel alloc] init];
    model.componentType = type;
    model.viewModel = viewModel;
    model.clickActionName = actionName;
    model.parent = parent;
    return model;
}

#pragma mark - Private

+ (NSString *)componentBackActionName:(id<DVEBarComponentProtocol>)component
{
    NSString *action = NSStringFromSelector(@selector(openParentComponent:));
    switch (component.componentType)
    {
        case DVEBarComponentTypeBlendCut:
        case DVEBarComponentTypeCut: {
            action = @"cutComponentClose:";
        } break;
        case DVEBarComponentTypeAudio: {
            action = @"audioComponentClose:";
        } break;
        case DVEBarComponentTypeFilterPartly:
        case DVEBarComponentTypeFilterGobal: {
            action = @"filterComponentClose:";
        } break;
        case DVEBarComponentTypeEffect: {
            action = @"effectComponentClose:";
        } break;
        case DVEBarComponentTypeRegulate: {
            action = @"regulateComponentClose:";
        } break;
        case DVEBarComponentTypeSticker: {
            action = @"stickerComponentClose:";
        } break;
        case DVEBarComponentTypePicInPic: {
            action = @"picInpicComponentClose:";
        } break;
        case DVEBarComponentTypeText: {
            action = @"textComponentClose:";
        } break;
//        case DVEBarComponentTypeTextTemplate: {
//            action = @"textTemplateComponentClose:";
//        } break;
        case DVEBarComponentTypeCanvasBackground: {
            action = @"canvasBackgroundComponentClose:";
        } break;
        default: {
        }
    }
    return action;
}

+ (NSArray *)parseSubComponentConfig:(NSArray *)subConfig
                              parent:(id<DVEBarComponentProtocol>)parent
                  createSubComponent:(BOOL)create
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:subConfig.count];
    DVEBarComponentModel *model = nil;
    for (NSObject *obj in subConfig) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *dic = (NSDictionary *)obj;
        NSNumber *type = [dic objectForKey:kTypeKey];
        if (!type) {
            continue;
        }

        NSString *title = [dic objectForKey:kTitleKey];
        UIImage *image = [dic objectForKey:kImageKey];
        NSURL *imageURL = [dic objectForKey:kUrlKey];
        DVEBarComponentViewModel *viewModel = nil;
        if (image || title || imageURL) {
            viewModel = [[DVEBarComponentViewModel alloc] initWithImage:image url:imageURL title:title];
        }

        NSString *action = [dic objectForKey:kActionKey];
        model = [DVEComponentModelFactory createComponentWithType:type.integerValue viewModel:viewModel actionName:action parent:parent createSubComponent:create];
        model.statusActionName = [dic objectForKey:kStatusKey];
        model.componentGroup = [[dic objectForKey:kGroupKey] integerValue];
        [array addObject:model];
    }
    return array;
}

#pragma mark - SubComponent

+ (NSArray *)defaultRootSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeCut)},///剪辑
        @{kTypeKey:@(DVEBarComponentTypeCanvas)},      ///尺寸
        @{kTypeKey:@(DVEBarComponentTypeCanvasBackground)}, ///画布
        @{kTypeKey:@(DVEBarComponentTypeAudio)},        ///音频
        @{kTypeKey:@(DVEBarComponentTypeSticker)},      ///贴纸
        @{kTypeKey:@(DVEBarComponentTypeText)},         ///文本
        @{kTypeKey:@(DVEBarComponentTypeFilterGobal)},       ///滤镜
        @{kTypeKey:@(DVEBarComponentTypeEffect)},  ///特效
        @{kTypeKey:@(DVEBarComponentTypeRegulate)},     ///调节
        @{kTypeKey:@(DVEBarComponentTypePicInPic)}, ///画中画
        @{kTypeKey:@(DVEBarComponentTypeBlendCut),kStatusKey:@"showBlendCutComponent:"},
        @{kTypeKey:@(DVEBarComponentTypeTransitionAnimation),kStatusKey:@"showTransitionAnimation:"},///转场动画
//        @{kTypeKey:@(DVEBarComponentTypeTextTemplate),kStatusKey:@"showTextTemplateStatus:"},//文本模板
    ];
}

+ (NSArray *)defaultCutSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeSplit)},    ///拆分
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_remove",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteMedia:"},
        @{kTypeKey:@(DVEBarComponentTypeSpeed)},    ///速度
        @{kTypeKey:@(DVEBarComponentTypeRotate)},   ///旋转
        @{kTypeKey:@(DVEBarComponentTypeFlip)},     ///翻转
        @{kTypeKey:@(DVEBarComponentTypeCrop)},    ///裁剪
        @{kTypeKey:@(DVEBarComponentTypeReverse)},  ///倒放
        @{kTypeKey:@(DVEBarComponentTypeSound),kStatusKey:@"openSoundStatus:"},    ///音量
        @{kTypeKey:@(DVEBarComponentTypeFilterPartly),kTitleKey:NLELocalizedString(@"ck_tab_filter",@"滤镜"),kImageKey:@"icon_vevc_add_filter".dve_toImage},   ///滤镜
        @{kTypeKey:@(DVEBarComponentTypeRegulate),kTitleKey:NLELocalizedString(@"ck_adjust",@"调节"), kImageKey:@"icon_vevc_tiaojie_regulate".dve_toImage, kActionKey:@"regulateComponentOpen:"}, ///调节
        @{kTypeKey:@(DVEBarComponentTypeMask)},     ///蒙版
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_change_voice",@"变声"),kImageKey:@"icon_audioeffect".dve_toImage,kActionKey:@"audioEffect:",kStatusKey:@"audioEffectStatus:"},//变声
        @{kTypeKey:@(DVEBarComponentTypeAnimation)}, ///动画
        @{kTypeKey:@(DVEBarComponentTypeMixedMode),kStatusKey:@"showMixedModeCompoment:"},//混合模式
        @{kTypeKey:@(DVEBarComponentTypeFreeze),kStatusKey:@"cut_freezeStatus:"},   ///定格
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_replace",@"替换"),kImageKey:@"icon_replace_video".dve_toImage,kActionKey:@"cut_replaceVideoOrImage:"}, // 替换
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_copy",@"复制"),kImageKey:@"icon_copy_video".dve_toImage,kActionKey:@"cut_copyVideoOrImageSlot:"}, // 复制
    ];
}

+ (NSArray *)defaultAudioSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_audio",@"添加音频"),kImageKey:@"icon_vevc_audio".dve_toImage,kActionKey:@"addAudio:"},//添加音频
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_sound_effect",@"添加音效"),kImageKey:@"icon_vevc_audioeffect".dve_toImage,kActionKey:@"addSound:"},//添加音效
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_audio_record",@"添加录音"),kImageKey:@"icon_vevc_recorder".dve_toImage,kActionKey:@"addSoundRecording:"},//添加录音
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_split",@"拆分"),kImageKey:@"icon_cutsub_chaifen".dve_toImage,kActionKey:@"audioSplit:",kGroupKey:@(DVEBarSubComponentGroupEdit)},//拆分
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_copy",@"复制"),kImageKey:@"icon_effects_copy".dve_toImage,kActionKey:@"audioCopy:",kGroupKey:@(DVEBarSubComponentGroupEdit)},//复制
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_volume",@"音量"),kImageKey:@"icon_cutsub_sound".dve_toImage,kActionKey:@"openSound:",kGroupKey:@(DVEBarSubComponentGroupEdit),kStatusKey:@"openSoundStatus:"},//音量
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteAudio:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_fade",@"淡化"),kImageKey:@"icon_vevc_audiofade".dve_toImage,kActionKey:@"audioFade:",kGroupKey:@(DVEBarSubComponentGroupEdit)},//淡化
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_change_voice",@"变声"),kImageKey:@"icon_audioeffect".dve_toImage,kActionKey:@"audioEffect:",kGroupKey:@(DVEBarSubComponentGroupEdit),kStatusKey:@"audioEffectStatus:"},//变声
        @{kTypeKey:@(DVEBarComponentTypeSound),kTitleKey:NLELocalizedString(@"ck_speed",@"速度"),kImageKey:@"icon_cutsub_sudu".dve_toImage,kActionKey:@"audioSpeed:",kGroupKey:@(DVEBarSubComponentGroupEdit)},//速度
    ];
}

+ (NSArray *)defaultEffectSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_effect",@"添加特效"),kImageKey:@"icon_vevc_add_effect".dve_toImage,kActionKey:@"openEffect:"},//添加特效
        @{kTypeKey:@(DVEBarComponentTypeEffectSubReplace),kGroupKey:@(DVEBarSubComponentGroupEdit)},    ///替换
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_copy",@"复制"),kImageKey:@"icon_effects_copy".dve_toImage,kActionKey:@"copyEffect:",kGroupKey:@(DVEBarSubComponentGroupEdit)},   ///复制
        @{kTypeKey:@(DVEBarComponentTypeEffectSubObject),kGroupKey:@(DVEBarSubComponentGroupEdit), kStatusKey:@"showParentEffectComponent:"},   ///作用对象
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteEffect:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
    ];
}

+ (NSArray *)defaultAnimationSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAnimationIn)},    ///入场动画
        @{kTypeKey:@(DVEBarComponentTypeAnimationOut)},   ///出场动画
        @{kTypeKey:@(DVEBarComponentTypeAnimationCombine)},   ///组合动画
    ];
}

+ (NSArray *)defaultStickerSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_sticker",@"添加贴纸"),kImageKey:@"icon_vevc_add_sticker".dve_toImage,kActionKey:@"openSticker:"},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_split",@"拆分"),kImageKey:@"icon_cutsub_chaifen".dve_toImage,kActionKey:@"splitSticker:",@"group":@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_copy",@"复制"),kImageKey:@"icon_effects_copy".dve_toImage,kActionKey:@"copySticker:",@"group":@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_animation",@"动画"),kImageKey:@"icon_cutsub_donghua".dve_toImage,kActionKey:@"showAnimation",@"group":@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteSticker",@"group":@(DVEBarSubComponentGroupEdit)}
    ];
}

+ (NSArray *)defaultTextSubComponent
{
    // note(caishaowu): 会根据 group 区分，既要满足编辑时需要，又要满足从编辑区返回情况，如删除
    return @[
#if ENABLE_SUBTITLERECOGNIZE
        @{kTypeKey:@(DVEBarComponentTypeTextRecognize),kTitleKey:NLELocalizedString(@"",@"识别字幕"),kImageKey:@"text_subtitle".dve_toImage,kActionKey:@"openRecognition:"},
#endif
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_text_template",@"文字模板"),kImageKey:@"icon_vevc_text_temp".dve_toImage,kActionKey:@"openTextTemplate:"},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_apply_text_sticker_cover",@"添加文字"),kImageKey:@"icon_vevc_text".dve_toImage,kActionKey:@"openText:"},
#if ENABLE_SUBTITLERECOGNIZE
        @{kTypeKey:@(DVEBarComponentTypeTextReader),kGroupKey:@(DVEBarSubComponentGroupEdit)},
#endif
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_replace",@"替换"),kImageKey:@"icon_text_template_replace".dve_toImage,kActionKey:@"replaceTextTemplate:",kGroupKey:@(DVEBarSubComponentGroupEdit),kStatusKey:@"showTextTemplateStatus:"},   //替换
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_split",@"拆分"),kImageKey:@"icon_cutsub_chaifen".dve_toImage,kActionKey:@"splitText:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_copy",@"复制"),kImageKey:@"icon_effects_copy".dve_toImage,kActionKey:@"copyText:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_edit",@"编辑"),kImageKey:@"icon_vevcbar_edit".dve_toImage,kActionKey:@"editText:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteText:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
    ];
}

+ (NSArray *)defaultFilterSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_filter",@"添加滤镜"),kImageKey:@"icon_vevc_add_filter".dve_toImage,kActionKey:@"openFilter:",kGroupKey:@(DVEBarSubComponentGroupAdd)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_change_filter",@"切换滤镜"),kImageKey:@"icon_vevc_add_filter".dve_toImage,kActionKey:@"changeFilter:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteFilter:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
    ];
}

+ (NSArray *)defaultRegulateSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_adjust",@"添加调节"),kImageKey:@"icon_vevc_tiaojie_regulate".dve_toImage,kActionKey:@"openRegulate:",kGroupKey:@(DVEBarSubComponentGroupAdd)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_adjust",@"调节"),kImageKey:@"icon_vevc_tiaojie_regulate".dve_toImage,kActionKey:@"editRegulate:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_delete",@"删除"),kImageKey:@"icon_cutsub_delet".dve_toImage,kActionKey:@"deleteRegulate:",kGroupKey:@(DVEBarSubComponentGroupEdit)},
    ];
}

+ (NSArray *)defaultPicInPicSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_add_pip",@"添加画中画"),kImageKey:@"icon_vevc_add_hzh".dve_toImage,kActionKey:@"addPicInPic:"},
    ];
}

+ (NSArray *)defaultSpeedSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_normal_speed",@"常规变速"),kImageKey:@"icon_vevcspeed_normal".dve_toImage,kActionKey:@"openNormalSpeed:"},
        @{kTypeKey:@(DVEBarComponentTypeAction),kTitleKey:NLELocalizedString(@"ck_curve_speed",@"曲线变速"),kImageKey:@"icon_vevcspeed_cuver".dve_toImage,kActionKey:@"openCurveSpeed:"},
    ];
}

+ (NSArray *)defaultCanvasBackgroundSubComponent
{
    return @[
        @{kTypeKey:@(DVEBarComponentTypeCanvasBackgroundColor),kTitleKey:NLELocalizedString(@"ck_canvas_color",@"画布颜色"),kImageKey:@"icon_vevc_canvascolor".dve_toImage,kActionKey:@"openCanvasBackgroundColor:"},
        @{kTypeKey:@(DVEBarComponentTypeCanvasBackgroundStyle),kTitleKey:NLELocalizedString(@"ck_canvas_style",@"画布样式"),kImageKey:@"icon_vevc_canvasstyle".dve_toImage,kActionKey:@"openCanvasBackgroundStyle:"},
        @{kTypeKey:@(DVEBarComponentTypeCanvasBackgroundBlur),kTitleKey:NLELocalizedString(@"ck_canvas_blur",@"画布模糊"),kImageKey:@"icon_vevc_canvasblur".dve_toImage,kActionKey:@"openCanvasBackgroundBlur:"},
    ];
}

@end
