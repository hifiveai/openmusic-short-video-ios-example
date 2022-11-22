//
//  DVEVideoCoverEditViewController.m
//  Pods
//
//  Created by bytedance on 2021/6/22.
//

#import "DVEVideoCoverEditViewController.h"
#import "DVEVCContext.h"
#import "DVEMacros.h"
#import "DVEPreview.h"
#import "DVECanvasVideoBorderView.h"
#import "DVEUIHelper.h"
#import "DVETextBar.h"
#import "DVEViewController.h"
#import "DVEVideoCoverAlbumImageCropView.h"
#import "DVEVideoCoverResourcePickerView.h"
#import "DVEVideoCoverBottomView.h"
#import "DVELoggerImpl.h"
#import "DVECustomerHUD.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "DVECoreCanvasProtocol.h"
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>
#import <DVETrackKit/UIView+VEExt.h>

#define kDVETextBarTag (23657)

static NSString * const kCoverSnapShotImage = @"CoverSnapshotSave";

@interface DVEVideoCoverEditViewController ()
<
DVEVideoCoverResourcePickerDelegate,
DVEVideoCoverAlbumImageCropDelegate,
DVEVideoCoverBottomViewDelegate
>

@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) DVEPreview *videoCoverPreview;
@property (nonatomic, strong) DVEVideoCoverResourcePickerView *pickerView;
@property (nonatomic, strong) DVEVideoCoverBottomView *bottomView;
@property (nonatomic, strong) NSMutableArray<UIImage *> *frames;
@property (nonatomic, assign) CMTime editTime;
@property (nonatomic, assign) CGFloat videoTimeLength;

@property (nonatomic, strong) NLEVideoFrameModel_OC *originCoverModel;
@property (nonatomic, strong) NLEVideoFrameModel_OC *coverModel;
@property (nonatomic, strong) UIImage *pickCropImage;

@property (nonatomic, strong) NSString *savedImagePath;
@property (nonatomic, assign) BOOL canvasBorderHidden;

@property (nonatomic, weak) id<DVECoreDraftServiceProtocol> draftService;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVEResourcePickerProtocol> resourcePicker;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;

@end

@implementation DVEVideoCoverEditViewController

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.vcContext.serviceProvider, draftService, DVECoreDraftServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

DVEOptionalInject(self.vcContext.serviceProvider, resourcePicker, DVEResourcePickerProtocol)

- (instancetype)initWithContext:(DVEVCContext *)context {
    if (self = [super init]) {
        _vcContext = context;
        _frames = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpLayout];
    [self setUpVideoClipSegmentData];
    [self cancelOperationForMainEdit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.coverModel) {
        return;
    }
    [self setUpObservers];
    [self removeEditBoxViewForMainEdit];
    [self restoreEditBoxViewForVideoCover];
}

- (void)setUpLayout {
    self.view.backgroundColor = colorWithHex(0x101010);
    
    self.videoCoverPreview = [self.parentVC videoPreview];
    [self.view addSubview:self.videoCoverPreview];
    [self.view addSubview:self.dismissButton];
    [self.view addSubview:self.resetButton];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.pickerView];
    [self.view addSubview:self.bottomView];
    
    self.dismissButton.top = (61 - VETopMargnValue) + [DVEUIHelper topBarMargn] - 10;
    self.dismissButton.left = 20;
    
    self.saveButton.top = (56 - VETopMargnValue) + [DVEUIHelper topBarMargn] - 10;
    self.saveButton.right = self.view.right - 14;
    self.resetButton.centerY = self.saveButton.centerY;
    self.resetButton.right = self.saveButton.left - 19;

    CGFloat originPreviewInset = self.videoCoverPreview.top;
    self.videoCoverPreview.top = originPreviewInset + self.saveButton.bottom;
    
    self.bottomView.width = self.view.width;
    self.bottomView.height = 64;
    self.bottomView.bottom = self.view.bottom - 34;
    self.bottomView.left = self.view.left;
    
    self.pickerView.width = self.view.width;
    self.pickerView.top = self.videoCoverPreview.bottom + originPreviewInset + 20;
    self.pickerView.height = self.view.height - self.videoCoverPreview.bottom - self.bottomView.height - 34 - originPreviewInset - 20;
    self.pickerView.left = self.view.left;
}

- (void)setUpVideoClipSegmentData {
    NLETrack_OC *mainTrack = [self.nleEditor.nleModel nle_getMainVideoTrack];
    NSArray<NLETrackSlot_OC *> *slots = [mainTrack slots];
    self.videoTimeLength = CMTimeGetSeconds([slots lastObject].endTime);
    [DVECustomerHUD showProgressInView:self.view];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        dispatch_group_t group = dispatch_group_create();
        for (NLETrackSlot_OC *slot in slots) {
            NLEResourceNode_OC *resource = [slot.segment getResNode];
            //如果slot资源类型是图片，则当为3s静止视频处理
            if (resource.resourceType == NLEResourceTypeImage) {
                NSString *path = [self.nle getAbsolutePathWithResource:resource];
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                for (NSInteger i = 0; i < 3; i++) {
                    [self.frames addObject:image];
                }
                continue;
            }
            dispatch_group_enter(group);
            [self getAllFramesFromSlot:slot
                            completion:^(NSMutableArray<UIImage *> * _Nullable frames) {
                for (UIImage *frame in frames) {
                    [self.frames addObject:frame];
                }
                dispatch_group_leave(group);
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            @strongify(self);
            [DVECustomerHUD hidProgressInView:self.view];
            [self.pickerView updateVideoFrames:self.frames];
            [self restoreNLEOperation];
        });
    });
}

- (void)setUpObservers {
    @weakify(self);
    [[[RACObserve(self.pickerView, currentType) deliverOnMainThread] skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.pickerView.currentType == DVEVideoCoverResourceTypeAlbumImage) {
            [self updateAlbumImageToCover];
        } else if (self.pickerView.currentType == DVEVideoCoverResourceTypeVideoFrame) {
            NLEStyCanvas_OC *coverMaterial = self.coverModel.coverMaterial;
            coverMaterial.canvasType = NLECanvasVideoFrame;
        }
        [self.actionService commitNLE:NO];
        [self seekToCurrentTime];//切换tab需要上层seekTime
    }];
    
    [[RACObserve(self, pickCropImage) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!self.pickCropImage) {
            return;
        }
        [self updateAlbumImageToCover];
    }];
    
    [[RACObserve(self.vcContext.mediaContext, selectTextSlot) skip:1] subscribeNext:^(NLETrackSlot_OC *_Nullable slot) {
        @strongify(self);
        //判断当前slot为空或者当前封面编辑页面已吊起文字面板
        if (!slot || [self.view viewWithTag:kDVETextBarTag]) {
            return;
        }
        NSString *segmentId = slot.nle_nodeId;
        [self showTextViewWithSegmentId:segmentId];
    }];
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] init];
        _dismissButton.size = CGSizeMake(17, 17);
        [_dismissButton setImage:[@"icon_close" dve_toImage] forState:UIControlStateNormal];
        @weakify(self);
        [[[_dismissButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            //退出需要恢复进入编辑页面时候的coverModel
            [self resetPrevNLEOperation];
            [self dismissOperation];
            //可能当前coverModel为undo/redo之后，此时退出也需要更新轨道区button缩略图
            if (self.coverModel.snapshot) {
                NSString *imagePath = [self.nle getAbsolutePathWithResource:self.coverModel.snapshot];
                UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCoverSnapShotImage object:image];
            }
        }];
    }
    return _dismissButton;
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] init];
        _resetButton.size = CGSizeMake(35, 16);
        [_resetButton setTitle:NLELocalizedString(@"ck_reset",@"重置" ) forState:UIControlStateNormal];
        _resetButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _resetButton.titleLabel.textColor = [UIColor whiteColor];
        _resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        @weakify(self);
        [[[_resetButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self resetOriginNLEOperation];
            //切换tab，重置回第一帧
            self.pickerView.currentType = DVEVideoCoverResourceTypeVideoFrame;
            [self.pickerView updateCurrentTimeRatio:0];
            //之前有相册图片的置空
            [self presentCropAlbumImageForVideoCover:nil];
        }];
    }
    return _resetButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        _saveButton.size = CGSizeMake(49, 26);
        [_saveButton setTitle:NLELocalizedString(@"ck_save_cover", @"保存")  forState:UIControlStateNormal];
        _saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _saveButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12];
        _saveButton.titleLabel.textColor = [UIColor whiteColor];
        _saveButton.layer.cornerRadius = 12;
        _saveButton.layer.borderWidth = 1;
        _saveButton.layer.masksToBounds = YES;
        _saveButton.backgroundColor = colorWithHex(0xFE6646);
        @weakify(self);
        [[[_saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self saveOperation];
        }];
    }
    return _saveButton;
}

- (DVEVideoCoverResourcePickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[DVEVideoCoverResourcePickerView alloc] init];
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (DVEVideoCoverBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[DVEVideoCoverBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

#pragma mark - Private

- (void)cancelOperationForMainEdit {
    self.canvasBorderHidden = [self.videoCoverPreview.canvasBorderView isHidden];
    [self.videoCoverPreview hideCanvasBorder];
}

- (void)restoreOperationForMainEdit {
    [self.videoCoverPreview showCanvasBorderEnableGesture:!self.canvasBorderHidden];
}

- (void)getAllFramesFromSlot:(NLETrackSlot_OC *)slot
                  completion:(void(^)(NSMutableArray<UIImage *> * _Nullable))completion {
    AVURLAsset *asset = [self.nle assetFromSlot:slot];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = CGSizeMake(150, 150);
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.appliesPreferredTrackTransform = YES;
    
    //考虑变速的影响
    CGFloat totalTime = CMTimeGetSeconds(slot.duration);
    int timeLength = (int)totalTime;
    
    NLESegmentVideo_OC *segment = (NLESegmentVideo_OC *)slot.segment;
    
    NSMutableArray<NSValue *> *values = [NSMutableArray array];
    NSMutableArray<UIImage *> *frames = [NSMutableArray array];
    for (NSInteger i = 0; i <= timeLength; i++) {
        //考虑变速的影响
        CGFloat time = (CGFloat)i + CMTimeGetSeconds(segment.timeClipStart);
        NSValue *value = [NSValue valueWithCMTime:CMTimeMake(time * USEC_PER_SEC, USEC_PER_SEC)];
        [values addObject:value];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [generator generateCGImagesAsynchronouslyForTimes:values
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef  _Nullable image,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image) {
            UIImage *frame = [UIImage imageWithCGImage:image];
            [frames addObject:frame];
        }
        if (frames.count == values.count) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (completion) {
        completion(frames);
    }
}

#pragma mark - NLE

//恢复上次的封面编辑
- (void)restoreNLEOperation {
    //标记主编辑页面的当前时间
    self.editTime = [self.vcContext.mediaContext currentTime];
    [self.vcContext.playerService seekToTime:kCMTimeZero isSmooth:NO];
    NLEModel_OC *editModel = self.nleEditor.nleModel;
    //若上次没有封面编辑，不用commit调用VE渲染
    if (!editModel.coverModel) {
        editModel.coverModel = [[NLEVideoFrameModel_OC alloc] init];
        editModel.coverModel.coverMaterial = [[NLEStyCanvas_OC alloc] init];
        editModel.coverModel.coverMaterial.canvasType = NLECanvasVideoFrame;
        editModel.coverModel.videoFrameTime = 0;
        editModel.coverModel.enable = YES;
    } else {
        NLECanvasType canvasType = editModel.coverModel.coverMaterial.canvasType;
        if (canvasType == NLECanvasImage) {
            NSString *albumImagePath = [self.nle getAbsolutePathWithResource:editModel.coverModel.coverMaterial.imageSource];
            UIImage *image = [UIImage imageWithContentsOfFile:albumImagePath];
            [self.pickerView updateCropAlbumImage:image];
        }
        editModel.coverModel.enable = YES;
        //若主编辑页面全局最大时间小于上次视频封面编辑保存的时间则重新置0
        NLETrack_OC *mainTrack = [self.nleEditor.nleModel nle_getMainVideoTrack];
        NSArray<NLETrackSlot_OC *> *slots = [mainTrack slots];
        CMTime lastTime = [slots lastObject].endTime;
        if (CMTimeCompare(lastTime, CMTimeMake(self.coverModel.videoFrameTime, USEC_PER_SEC)) < 0) {
            editModel.coverModel.videoFrameTime = 0;
        }
        [self.actionService commitNLE:NO];
        [self seekToCurrentTime];//进入封面编辑时需要seekTime
    }
    
    self.coverModel = editModel.coverModel;
    self.originCoverModel = [editModel.coverModel deepClone];
    
    if (self.pickerView.currentType == DVEVideoCoverResourceTypeVideoFrame) {
        [self.pickerView updateCurrentTimeRatio:self.coverModel.videoFrameTime * 1.0 / USEC_PER_SEC / self.videoTimeLength];
    }
}

- (void)resetPrevNLEOperation {
    self.originCoverModel.enable = NO;
    self.nleEditor.nleModel.coverModel = self.originCoverModel;
    [self.actionService commitNLE:NO];
}

- (void)resetOriginNLEOperation {
    //重置会视频帧类型，默认时间为0
    self.coverModel.coverMaterial.imageSource = nil;
    self.coverModel.videoFrameTime = 0;
    self.coverModel.coverMaterial.canvasType = NLECanvasVideoFrame;
    //删除所有编辑框
    [self removeEditBoxViewForVideoCover];
    //删除所有贴纸轨道
    NSArray<NLETrack_OC *> *tracks = [self.coverModel tracks];
    for (NLETrack_OC *track in tracks) {
        [self.coverModel removeTrack:track];
    }
    
    [self.actionService commitNLE:NO];
    [self seekToCurrentTime];//重置后上层需要seekTime
}

- (void)seekToCurrentTime {
    CMTime seekTime = kCMTimeZero;
    if (self.coverModel.coverMaterial.canvasType == NLECanvasVideoFrame) {
        seekTime = CMTimeMake(self.coverModel.videoFrameTime, USEC_PER_SEC);
    }
    [self.vcContext.playerService seekToTime:seekTime isSmooth:YES];
}

- (void)updateAlbumImageToCover {
    NLEStyCanvas_OC *coverMaterial = self.coverModel.coverMaterial;
    coverMaterial.canvasType = NLECanvasImage;
    if (!coverMaterial.imageSource) {
        coverMaterial.imageSource = [[NLEResourceNode_OC alloc] init];
    }
    //没有更新相册图片，仅是切换currentType
    if (!self.pickCropImage) {
        return;
    }
    NSString *imagePath = [self.draftService.currentDraftPath stringByAppendingPathComponent:[NSString VEUUIDString]];
    [UIImageJPEGRepresentation(self.pickCropImage, 1) writeToFile:imagePath atomically:YES];
    coverMaterial.imageSource.resourceFile = [imagePath lastPathComponent];
    //删除上一次缓存的相册图片
    if (self.savedImagePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.savedImagePath error:nil];
    }
    self.savedImagePath = imagePath;
}

#pragma mark - Dismiss

- (void)saveOperation {
    CGFloat time = 0;
    if (self.pickerView.currentType == DVEVideoCoverResourceTypeVideoFrame) {
        time = self.coverModel.videoFrameTime * 1.0 / USEC_PER_SEC;
    }
    
    if (!self.coverModel.snapshot) {
        self.coverModel.snapshot = [[NLEResourceNode_OC alloc] init];
        self.coverModel.snapshot.resourceType = NLEResourceTypeImage;
    }

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //封面编辑的缩略图
        @weakify(self);
        CGSize preferredSize = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) canvasSize];
        [self.vcContext.playerService getProcessedPreviewImageAtTime:time
                                                   preferredSize:preferredSize
                                                     compeletion:^(UIImage * image, NSTimeInterval atTime) {
            if (!image) {
                DVELogError(@"cover image exported fail!!!!");
            } else {
                @strongify(self);
                NSString *snapshotPath = [self.draftService.currentDraftPath stringByAppendingPathComponent:[NSString VEUUIDString]];
                [UIImageJPEGRepresentation(image, 1) writeToFile:snapshotPath atomically:YES];
                self.coverModel.snapshot.resourceFile = [snapshotPath lastPathComponent];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCoverSnapShotImage object:image];
            }
            dispatch_group_leave(group);
        }];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.coverModel.enable = NO;
        [self.actionService commitNLE:YES];
        [self dismissOperation];
    });
}

- (void)dismissOperation {
    self.vcContext.mediaContext.currentTime = self.editTime;
    [self.vcContext.playerService seekToTime:self.editTime isSmooth:NO];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
        
    }];
    [self removeEditBoxViewForVideoCover];
    [self restoreEditBoxViewForMainEdit];
    [self restoreOperationForMainEdit];
    
    //当前选中的文本slot是属于cover的时候需要取消选中
    NSString *segmentId = self.vcContext.mediaContext.selectTextSlot.nle_nodeId;
    NLETrackSlot_OC *slot = [self.coverModel slotOf:segmentId];
    if (slot) {
        self.vcContext.mediaContext.selectTextSlot = nil;
    }
}

#pragma mark - StickerEditBox

//重新回到封面编辑页面，文字贴纸相关的editBox要恢复
- (void)restoreEditBoxViewForVideoCover {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel.coverModel tracks];
    [self p_addStickerEditBoxWithTracks:tracks];
}

//回到主编辑页面，封面编辑页面的editBox要删除
- (void)removeEditBoxViewForVideoCover {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel.coverModel tracks];
    [self p_removeStickerEditBoxWithTracks:tracks];
}

//添加回主编辑页面的所有editBox
- (void)restoreEditBoxViewForMainEdit {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
    [self p_addStickerEditBoxWithTracks:tracks];
}

//删除主编辑页面的所有sticker editBox
- (void)removeEditBoxViewForMainEdit {
    NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
    [self p_removeStickerEditBoxWithTracks:tracks];
}

- (void)p_addStickerEditBoxWithTracks:(NSArray<NLETrack_OC *> *)tracks {
    for (NLETrack_OC *track in tracks) {
        if (track.extraTrackType != NLETrackSTICKER) {
            continue;
        }
        NSArray<NLETrackSlot_OC *> *slots = [track slots];
        for (NLETrackSlot_OC *slot in slots) {
            [self.parentVC.stickerEditAdatper addEditBoxForSticker:slot.nle_nodeId];
        }
    }
    //默认不激活editBox
    [self.parentVC.stickerEditAdatper activeEditBox:nil];
    [self.parentVC.stickerEditAdatper changeSelectTextSlot:nil];
}

- (void)p_removeStickerEditBoxWithTracks:(NSArray<NLETrack_OC *> *)tracks {
    for (NLETrack_OC *track in tracks) {
        if (track.extraTrackType != NLETrackSTICKER) {
            continue;
        }
        NSArray<NLETrackSlot_OC *> *slots = [track slots];
        for (NLETrackSlot_OC *slot in slots) {
            [self.parentVC.stickerEditAdatper removeStickerBox:slot.nle_nodeId];
        }
    }
}

#pragma mark - DVEVideoCoverResourcePickerDelegate

- (void)pickAlbumImageWithCompletion:(void (^)(UIImage * _Nullable))completion {
    [self.resourcePicker pickSingleImageResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
        id<DVEResourcePickerModel> resourcePickerModel = [resources firstObject];
        if (completion) {
            completion(resourcePickerModel.image);
        }
    }];
}

- (void)updatePreviewCurrentTimeWithRatio:(CGFloat)ratio {
    self.coverModel.videoFrameTime = ratio * self.videoTimeLength * USEC_PER_SEC;
    CMTime time = CMTimeMake(self.coverModel.videoFrameTime, USEC_PER_SEC);
    [self.vcContext.playerService seekToTime:time isSmooth:NO];
}

- (void)showAlbumImageCropViewWithImage:(UIImage *)image {
    DVEVideoCoverAlbumImageCropView *imageCropView = [[DVEVideoCoverAlbumImageCropView alloc] initWithImage:image
                                                                                                   delegate:self];
    CGSize canvasSize = [self.canvasEditor canvasSizeScaleAspectFitInRect:CGRectMake(0, 0, self.view.width, self.videoCoverPreview.bottom)];
    imageCropView.canvasSize = canvasSize;
    [self.view addSubview:imageCropView];
}

#pragma mark - DVEVideoCoverAlbumImageCropDelegate

- (void)presentCropAlbumImageForVideoCover:(UIImage * _Nullable)cropImage {
    self.pickCropImage = cropImage;
    [self.pickerView updateCropAlbumImage:cropImage];
}

- (void)backImageResourcePickerView {
    @weakify(self);
    [self.resourcePicker pickSingleImageResourceWithCompletion:^(NSArray<id<DVEResourcePickerModel>> * _Nonnull resources, NSError * _Nullable error, BOOL cancel) {
        if (resources.count <= 0) {
            return;
        }
        @strongify(self);
        id<DVEResourcePickerModel> resourcePickerModel = [resources firstObject];
        [self showAlbumImageCropViewWithImage:resourcePickerModel.image];
    }];
}

#pragma mark - DVEVideoCoverBottomViewDelegate

- (void)showTextView {
    if (self.pickerView.currentType == DVEVideoCoverResourceTypeVideoFrame) {
        //需要更新currentTime，保证文字面板弹起的时候是当前时间
        self.vcContext.mediaContext.currentTime = CMTimeMake(self.coverModel.videoFrameTime, USEC_PER_SEC);
    }
    NSString *segmentId = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreStickerProtocol) addNewRandomPositionTextStickerForVideoCover:self.coverModel startTime:0 duration:self.videoTimeLength];
    [self showTextViewWithSegmentId:segmentId];
}

- (void)showTextViewWithSegmentId:(NSString *)segmentId {
    [self.parentVC showEditStickerViewWithType:VEVCStickerEditTypeText];
    [self.parentVC.stickerEditAdatper addEditBoxForStickerWithVideoCover:self.coverModel
                                                               segmentId:segmentId];
    CGFloat H = 291 + 108 - VEBottomMargnValue + VEBottomMargn;
    CGFloat Y = VE_SCREEN_HEIGHT - H;
    DVETextBar* textBar = [[DVETextBar alloc] initWithFrame:CGRectMake(0, Y, VE_SCREEN_WIDTH, H)];
    textBar.segmentId = segmentId;
    textBar.isMainEdit = NO;
    textBar.vcContext = self.vcContext;
    textBar.parentVC = self.parentVC;
    textBar.tag = kDVETextBarTag;
    [textBar updateTextCategoryWithNames:@[NLELocalizedString(@"ck_text_keyboard", @"键盘"),NLELocalizedString(@"ck_text_style",@"样式"),NLELocalizedString(@"ck_text_flower",@"花字"), NLELocalizedString(@"ck_text_bubble",@"气泡")]];
    [textBar showInView:self.view animation:YES];
}

@end
