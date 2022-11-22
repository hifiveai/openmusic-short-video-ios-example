//
//  DVEVCContext.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVCContext.h"
#import "DVEAlbumResourcePicker.h"
#import "DVECommonDefine.h"
#import "DVECustomerHUD.h"
#import "DVEDraftModel.h"
#import "DVELoggerImpl.h"
#import "DVELoggerService.h"
#import "DVEMacros.h"
#import "DVEMaskConfigModel.h"
#import "DVETextParm.h"
#import "NSArray+RGBA.h"
#import "NSDictionary+DVE.h"
#import "NSString+DVE.h"
#import "NSString+VEIEPath.h"
#import "NSString+VEToImage.h"
#import "DVEServiceLocator.h"
#import "DVEToast.h"

#import <mach/mach_time.h>
#import <DVETrackKit/DVECGUtilities.h>
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <MJExtension/MJExtension.h>
#import <NLEPlatform/NLEInterface.h>
#import <NLEPlatform/NLESegmentInfoSticker+iOS.h>
#import <TTVideoEditor/HTSVideoData+Dictionary.h>
#import <TTVideoEditor/VECompileTaskManagerSession.h>
#import <TTVideoEditor/VEVideoAnimation.h>

#import "DVEEditorEventProtocol.h"
#import "DVEVCContextServiceContainer.h"
#import "DVEVCContextExternalInjectProtocol.h"
#import "DVEAnimationEditorWrapper.h"
#import "DVEAudioEditorWrapper.h"
#import "DVECanvasEditorWrapper.h"
#import "DVEDraftService.h"
#import "DVEEffectEditorWrapper.h"
#import "DVEFilterEditorWrapper.h"
#import "DVEMaskEditorWrapper.h"
#import "DVERegulateEditorWrapper.h"
#import "DVESlotEditorWrapper.h"
#import "DVEStickerEditorWrapper.h"
#import "DVETextEditorWrapper.h"
#import "DVETextTemplateEditorWrapper.h"
#import "DVETransitionEditorWrapper.h"
#import "DVEVideoEditorWrapper.h"
#import "DVEKeyFrameEditorWrapper.h"

#import "DVEActionService.h"
#import "DVEDraftService.h"
#import "DVEExportService.h"
#import "DVEImportService.h"
#import "DVEPlayerService.h"

#import "DVENLEEditorWrapper.h"
#import "DVENLEInterfaceWrapper.h"

#define kVED_NLE_ExtKey_AVAssetDirURL @"draftPath"

@interface DVEVCContext ()
<
NLEEditorDelegate,
DVEMediaContextPlayerDelegate,
DVEMediaContextNLEEditorDelegate,
DVEMediaContextNLEInterfaceDelegate,
NLEEditor_iOSListenerProtocol
>

@property (nonatomic, strong) NLEInterface_OC *nle;

@property (nonatomic, strong, readwrite) id<DVEServiceProvider> serviceProvider;
@property (nonatomic, weak) DVEVCContextServiceContainer* serviceContainer;

@property (nonatomic, strong, readwrite) DVEMediaContext *mediaContext;
@property (nonatomic, strong, readwrite) id<DVEPlayerServiceProtocol> playerService;

@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;
@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreExportServiceProtocol> exportService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVECoreKeyFrameProtocol> keyFrameEditor;
@end

@implementation DVEVCContext

DVEAutoInject(self.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.serviceProvider, exportService, DVECoreExportServiceProtocol)
DVEAutoInject(self.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.serviceProvider, keyFrameEditor, DVECoreKeyFrameProtocol)

#pragma mark - Instance LifeCycle

- (void)dealloc
{
    DVELogInfo(@"VEVCContext dealloc");
    _serviceProvider = nil;
}

- (instancetype)initWithDraftModel:(DVEDraftModel *)draftModel
                     injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    self = [self init];
    [self initServiceInject];
    [self initExternalServiceInject:injectService];

    [self creatNLEEditor];
    self.playerService = [[DVEPlayerService alloc] initWithNLEInterface:self.nle];
    [self.draftService restoreDraftModel:draftModel];
    self.mediaContext = [self createMediaContext];
    [self.canvasEditor restoreCanvasSize];
    if (!DVE_FLOAT_EQUAL_TO(self.canvasEditor.canvasSize.height, 0)) {
        self.nleEditor.nleModel.canvasRatio = self.canvasEditor.canvasSize.width / self.canvasEditor.canvasSize.height;
    }
    [self.mediaContext updateMappingTimelineVideoSlot];
    [self.nleEditor commit];
    return self;
}

- (instancetype)initWithModels:(NSArray<id<DVEResourcePickerModel>> *)resources
                 injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    self = [self init];
    [self initServiceInject];
    [self initExternalServiceInject:injectService];

    [self creatNLEEditor];
    self.playerService = [[DVEPlayerService alloc] initWithNLEInterface:self.nle];
    [self.canvasEditor initCanvasWithResource:resources.firstObject];
    if (!DVE_FLOAT_EQUAL_TO(self.canvasEditor.canvasSize.height, 0)) {
        self.nleEditor.nleModel.canvasRatio = self.canvasEditor.canvasSize.width / self.canvasEditor.canvasSize.height;
    }
    [self.draftService createDraftModel];
    self.mediaContext = [self createMediaContext];
    [DVEAutoInline(self.serviceProvider, DVECoreImportServiceProtocol) addNLEMainVideoWithResources:resources completion:nil];
    [self.mediaContext updateMappingTimelineVideoSlot];
    return self;
}

- (instancetype)initWithNLEModelString:(NSString *)nleModelString draftFolder:(NSString *)draftFolder injectService:injectService
{
    self = [self init];
    [self initServiceInject];
    [self initExternalServiceInject:injectService];
    HTSVideoData *videoData = [HTSVideoData videoData];
    // copy draft folder to "DVEEditorDraft"
    NSString *newPath = [NSString VEUUIDString];
    NSURL *newUrl = [NSURL URLWithString:[self.draftService.draftRootPath stringByAppendingFormat:@"/%@", newPath]];
    
    NSURL *draftUrl = [NSURL URLWithString:draftFolder];
    if (draftUrl) {
        NSString *relativePath = [self.draftService copyResourceToDraft:draftUrl resourceType:NLEResourceTypeDraft];
        NSURL *dveUrl = [NSURL URLWithString:[self.draftService.draftRootPath stringByAppendingFormat:@"/%@", relativePath]];
        NSError *error;        
        [NSFileManager.defaultManager moveItemAtURL:[NSURL fileURLWithPath:dveUrl.absoluteString isDirectory:YES] toURL:[NSURL fileURLWithPath:newUrl.absoluteString isDirectory:YES] error:&error];
        if (error) {
            DVELogError(@"移动草稿目录失败 %@", error);
            return nil;
        }
        [NSFileManager.defaultManager removeItemAtURL:[NSURL fileURLWithPath:dveUrl.absoluteString isDirectory:YES] error:nil];
    }
    // 创建draftModel, 并把draftID设为新ID
    DVEDraftModel *draftModel = [[DVEDraftModel alloc] init];
    draftModel.draftID = newPath;
    NSString *df = newUrl.absoluteString;
    [self createNLEEditor:videoData nleModel:nleModelString draftFolder:df];
    self.playerService = [[DVEPlayerService alloc] initWithNLEInterface:self.nle];
    self.draftService.draftModel = draftModel;

    self.mediaContext = [self createMediaContext];
    [self.canvasEditor restoreCanvasSize];
    [self.actionService commitNLEWithoutNotify:NO];
    return self;
}

#pragma mark - Factory

- (void)creatNLEEditor
{
    self.nle = [[NLEInterface_OC alloc] init];
    
    VEEditorSessionConfig *config = [VEEditorSessionConfig new];
    config.useNewMudule = YES;
    config.enableMultiTrack = YES;
    config.enableKeyFrameFeature = YES;
    NLEEditorConfiguration *nleConfig = [[NLEEditorConfiguration alloc] init];
    nleConfig.veConfig = config;

    [self.nle CreateNLEEditorWithConfiguration:nleConfig];
    [self configNLEInject];

    self.nle.draftFolder = [self.draftService.draftRootPath stringByAppendingPathComponent:self.draftService.draftModel.draftID];
    [self.nleEditor.nleModel setExtra:self.nle.draftFolder forKey:kVED_NLE_ExtKey_AVAssetDirURL];
    [self.nleEditor addDelegate:self];
    [self.nleEditor addListener:self];
}

- (void)createNLEEditor:(HTSVideoData *)videoData nleModel:(NSString *)nleModelString draftFolder:(NSString *)draftFolder
{
    self.nle = [[NLEInterface_OC alloc] init];
    self.nle.draftFolder = draftFolder;
    
    VEEditorSessionConfig *config = [VEEditorSessionConfig new];
    config.useNewMudule = YES;
    config.enableMultiTrack = YES;
    config.enableKeyFrameFeature = YES;
    NLEEditorConfiguration *nleConfig = [[NLEEditorConfiguration alloc] init];
    nleConfig.veConfig = config;

    [self.nle CreateNLEEditorWithConfiguration:nleConfig];
    [self configNLEInject];

    [self.nleEditor restore:nleModelString];
    [self.nleEditor addDelegate:self];
    [self.nleEditor addListener:self];
    
    if (!CGSizeEqualToSize(self.canvasEditor.canvasSize, CGSizeZero)) {
        [self.nleEditor nleModel].canvasRatio = self.canvasEditor.canvasSize.width / self.canvasEditor.canvasSize.height;
    }

//    self.nle.veEditor.stickerRecoverEvent = [self.nle getNLEStickerRecoverActionBlock];
}

- (DVEMediaContext *)createMediaContext
{
    DVEMediaContext *mediaContext = [[DVEMediaContext alloc] init];
    mediaContext.nleEditorDelegate = self;
    mediaContext.playerDelegate = self;
    mediaContext.nleInterfaceDelegate = self;
    return mediaContext;
}

#pragma mark - NLEEditorDelegate

- (void)nleEditorDidChange:(NLEEditor_OC *)editor
{
    DVELogInfo(@"undoredo--------------nleModelChanged");
    [self.actionService refreshUndoRedo];
}

#pragma mark - DVEMediaContextPlayerDelegate

- (void)mediaDelegateSeekToTime:(CMTime)time
                       isSmooth:(BOOL)isSmooth
{
    [self.playerService seekToTime:time isSmooth:isSmooth];
}

- (NSTimeInterval)currentPlayerTime
{
    return self.playerService.currentPlayerTime;
}

- (void)mediaDelegatePause
{
    [self.playerService pause];
}

- (HTSPlayerStatus)mediaDelegateStatus
{
    // VE：HTSPlayerStatus
    // NLEEditor：VEVCPlayerStatus
    return (HTSPlayerStatus)self.playerService.status;
}

- (RACSignal<NSNumber *> *)playerTimeDidChangeSignal
{
    return RACObserve(self.playerService, currentPlayerTime);
}

#pragma mark - DVEMediaContextNLEInterfaceDelegate

- (AVURLAsset *)mediaDelegateAssetFromSlot:(NLETrackSlot_OC *)slot
{
    return [self.nle assetFromSlot:slot];
}

- (NSString *)mediaDelegateGetAbsolutePathWithResource:(NLEResourceNode_OC *)resourceNode
{
    return [self.nle getAbsolutePathWithResource:resourceNode];
}

#pragma mark - DVEMediaContextNLEEditorDelegate

- (void)mediaDelegateAddNLEEditorDelegate:(id<NLEEditorDelegate>)delegate
{
    [self.nleEditor addDelegate:delegate];
}

- (void)mediaDelegateRemoveNLEEditorDelegate:(id<NLEEditorDelegate>)delegate
{
    [self.nleEditor removeDelegate:delegate];
}

- (void)mediaDelegateAddNLEEditorListener:(id<NLEEditor_iOSListenerProtocol>)listener
{
    [self.nleEditor addListener:listener];
}

- (void)mediaDelegateCommit
{
    [self.nleEditor commit];
}

- (BOOL)mediaDelegateDone
{
    return [self.nleEditor done];
}

- (NLEModel_OC *)mediaDelegateNLEModel
{
    return self.nleEditor.nleModel;
}

-(CMTime)currentKeyframeTimeRange
{
    return [self.keyFrameEditor currentKeyframeTimeRange];
}

#pragma mark - Inject

- (void)initServiceInject
{
    DVEVCContextServiceContainer *container = [[DVEVCContextServiceContainer alloc] initWithParentContainer:DVEGlobalContainer()];
    self.serviceProvider = [[DVEVCContextServiceProvider alloc] initWithContainer:container];
    self.serviceContainer = container;
    
    @weakify(self);
    /// 视频
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEVideoEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreVideoProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 音频
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEAudioEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreAudioProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 文字
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVETextEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreTextProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 文字模板
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVETextTemplateEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreTextTemplateProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 特效
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEEffectEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreEffectProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 滤镜
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEFilterEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreFilterProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 贴纸
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEStickerEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreStickerProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 蒙版
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEMaskEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreMaskProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 调节
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVERegulateEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreRegulateProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 动画
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEAnimationEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreAnimationProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 转场
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVETransitionEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreTransitionProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 画布
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVECanvasEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreCanvasProtocol) scope:DVEInjectScopeTypeSingleton];
    
    /// 关键帧
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEKeyFrameEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreKeyFrameProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 草稿
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEDraftService alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreDraftServiceProtocol) scope:DVEInjectScopeTypeSingleton];

    ///导入
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEImportService alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreImportServiceProtocol) scope:DVEInjectScopeTypeSingleton];

    /// 导出
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEExportService alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreExportServiceProtocol) scope:DVEInjectScopeTypeSingleton];

    /// undo/redo/commit
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVEActionService alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreActionServiceProtocol) scope:DVEInjectScopeTypeSingleton];
    
    /// 贴纸
    [container registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVESlotEditorWrapper alloc] initWithContext:self];
    } forProtocol:@protocol(DVECoreSlotProtocol) scope:DVEInjectScopeTypeSingleton];
}

- (void)initExternalServiceInject:(id<DVEVCContextExternalInjectProtocol>)serviceInject
{
    if (serviceInject) {
#if ENABLE_SUBTITLERECOGNIZE
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideSubtitleNetService)]){
                return [serviceInject provideSubtitleNetService];
            }
            return nil;
        } forProtocol:@protocol(DVESubtitleNetServiceProtocol) scope:DVEInjectScopeTypeSingleton];
        
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideTextReaderService)]){
                return [serviceInject provideTextReaderService];
            }
            return nil;
        } forProtocol:@protocol(DVETextReaderServiceProtocol) scope:DVEInjectScopeTypeSingleton];
#endif
        
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideDVELogger)]){
                return [serviceInject provideDVELogger];
            }
            return nil;
        } forProtocol:@protocol(DVELoggerProtocol) scope:DVEInjectScopeTypeSingleton];
        
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideResourcePicker)]){
                return [serviceInject provideResourcePicker];
            } else {
#if ENABLE_DVEALBUM
                DVEAlbumResourcePicker *resourcePicker = [[DVEAlbumResourcePicker alloc] init];
                return resourcePicker;
#endif
            }
            return nil;
        } forProtocol:@protocol(DVEResourcePickerProtocol) scope:DVEInjectScopeTypeSingleton];
        
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideResourceLoader)]){
                return [serviceInject provideResourceLoader];
            }
            return nil;
        } forProtocol:@protocol(DVEResourceLoaderProtocol) scope:DVEInjectScopeTypeSingleton];
        
        [self.serviceContainer registerProvider:^id _Nonnull{
            if([serviceInject respondsToSelector:@selector(provideEditorEvent)]){
                return [serviceInject provideEditorEvent];
            }
            return nil;
        } forProtocol:@protocol(DVEEditorEventProtocol) scope:DVEInjectScopeTypeSingleton];
        
        [DVELoggerService shareManager].logger = DVEOptionalInline(self.serviceProvider, DVELoggerProtocol);
        id<DVEEditorEventProtocol> config = DVEOptionalInline(self.serviceProvider, DVEEditorEventProtocol);
        if ([config respondsToSelector:@selector(effectPathSearchBlock)] && [config effectPathSearchBlock]) {
            [self.nle.veEditor setEffectPathBlock:[config effectPathSearchBlock]];
        }
    }
}

- (void)configNLEInject
{
    @weakify(self);
    [self.serviceContainer registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVENLEEditorWrapper alloc] initWithNLEEditor:self.nle.editor];
    } forProtocol:@protocol(DVENLEEditorProtocol) scope:DVEInjectScopeTypeSingleton];

    [self.serviceContainer registerProvider:^id _Nonnull{
        @strongify(self);
        return [[DVENLEInterfaceWrapper alloc] initWithNLEInterface:self.nle];
    } forProtocol:@protocol(DVENLEInterfaceProtocol) scope:DVEInjectScopeTypeSingleton];
}

#pragma mark - Setter

- (void)setPlayerService:(DVEPlayerService *)playerService
{
    _playerService = playerService;
    [self p_syncUserParm];
}

- (void)p_syncUserParm
{
    [self.exportService setExportPresentSelectIndex:1];
    [self.exportService setExportFPSSelectIndex:1];
}

@end
