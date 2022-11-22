//
//  DVEViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEVideoCutBaseViewController.h"
#import "DVEStickerEditAdpter.h"
#import "DVEMaskEditAdpter.h"
#import "DVEResourcePickerProtocol.h"
#import "DVEPreview.h"

NS_ASSUME_NONNULL_BEGIN

@class HTSVideoData, DVEDraftModel, DVEMaskBar;

@interface DVEViewController : DVEVideoCutBaseViewController<DVEStickerEditAdpterDelegate>

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSArray<id<DVEResourcePickerModel>> * _Nullable resources;
@property (nonatomic, strong) DVEStickerEditAdpter *stickerEditAdatper;
@property (nonatomic, strong) DVEMaskEditAdpter *maskEditAdpter;

#pragma mark - init

+ (instancetype)vcWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources;

+ (instancetype)vcWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                  injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

- (instancetype)initWithDraftModel:(DVEDraftModel *)draftModel
                     injectService:(id<DVEVCContextExternalInjectProtocol>)injectService;

- (instancetype)initWithModelString:(NSString *)nleModelString draftFolder:(NSString *)draftFolder injectService:injectService;

#pragma mark - Sticker

- (void)showEditStickerViewWithType:(VEVCStickerEditType)type;

- (void)dismissEditStickerView;

#pragma mark - Mask

- (void)showEditMaskViewConfigModel:(DVEMaskConfigModel *)model withBar:(DVEMaskBar*)bar;

- (void)dismissEditMaskView;

#pragma mark - Canvas

- (void)setCanvasRatio:(DVECanvasRatio )ratio;

- (void)showCanvasBorderIfNeededEnableGesture:(BOOL)enableGesture;

#pragma mark - Preview

- (DVEPreview *)videoPreview;

- (void)resetVideoPreview;

@end

NS_ASSUME_NONNULL_END
