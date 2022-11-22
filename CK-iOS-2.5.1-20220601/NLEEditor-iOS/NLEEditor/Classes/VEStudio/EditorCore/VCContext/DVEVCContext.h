//
//  DVEVCContext.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DVEEffectValue.h"
#import "DVEResourceLoaderProtocol.h"
#import "DVEResourcePickerProtocol.h"
#import "NLEResourceAV_OC+NLE.h"

#import <DVETrackKit/DVEMediaContext+AudioOperation.h>
#import <DVETrackKit/DVEMediaContext+Blend.h>
#import <DVETrackKit/DVEMediaContext+VideoOperation.h>
#import <DVETrackKit/DVEMediaContext+SlotUtils.h>
#import <DVETrackKit/DVEMediaContext.h>
#import <DVETrackKit/NLENode_OC+NLE.h>
#import <DVETrackKit/NLETimeSpaceNode_OC+NLE.h>
#import <DVETrackKit/NLETrackSlot_OC+NLE.h>
#import <DVETrackKit/NLEVideoAnimation_OC+NLE.h>
#import <NLEPlatform/NLEInterface.h>

#import "DVEVCContextServiceProvider.h"
#import "DVECoreAnimationProtocol.h"
#import "DVECoreAudioProtocol.h"
#import "DVECoreCanvasProtocol.h"
#import "DVECoreEffectProtocol.h"
#import "DVECoreFilterProtocol.h"
#import "DVECoreMaskProtocol.h"
#import "DVECoreRegulateProtocol.h"
#import "DVECoreSlotProtocol.h"
#import "DVECoreStickerProtocol.h"
#import "DVECoreTextProtocol.h"
#import "DVECoreTextTemplateProtocol.h"
#import "DVECoreTransitionProtocol.h"
#import "DVECoreVideoProtocol.h"
#import "DVECoreKeyFrameProtocol.h"

#import "DVECoreActionServiceProtocol.h"
#import "DVECoreDraftServiceProtocol.h"
#import "DVECoreExportServiceProtocol.h"
#import "DVECoreImportServiceProtocol.h"

#import "DVEPlayerServiceProtocol.h"
#import "DVENLEEditorProtocol.h"
#import "DVENLEInterfaceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEDraftModel, DVEMaskConfigModel;
@protocol DVEVCContextExternalInjectProtocol;

@interface DVEVCContext : NSObject

///DI 注入服务提供者
@property (nonatomic, strong, readonly) id<DVEServiceProvider> serviceProvider;

// 轨道区上下文
@property (nonatomic, strong, readonly) DVEMediaContext *mediaContext;

// 播放器职责承担者
@property (nonatomic, strong, readonly) id<DVEPlayerServiceProtocol> playerService;

- (instancetype)initWithDraftModel:(DVEDraftModel *)draftModel
                     injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

- (instancetype)initWithModels:(NSArray<id<DVEResourcePickerModel>> *)models
                 injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

- (instancetype)initWithNLEModelString:(NSString *)nleModelString draftFolder:(NSString *)draftFolder injectService:injectService;

@end

NS_ASSUME_NONNULL_END
