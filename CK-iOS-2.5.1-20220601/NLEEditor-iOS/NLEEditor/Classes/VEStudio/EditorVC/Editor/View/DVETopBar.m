//
//  DVETopBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETopBar.h"
#import "DVEPopSelectView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "NSString+VEToImage.h"
#import "DVECustomerHUD.h"
#import "DVEToast.h"
#import "DVEDataCache.h"
#import "DVEComponentViewManager.h"
#import "DVEEditorEventProtocol.h"
#import "DVELoggerImpl.h"
#import "DVEServiceLocator.h"
#import "DVEEditorEventProtocol.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import "DVEDraftModel.h"
#import "DVEReportUtils.h"
#import <DVETrackKit/DVEUILayout.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Photos/Photos.h>
#import <DVETrackKit/DVEConfig.h>

@interface DVETopBar ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *fpsButton;
@property (nonatomic, strong) UIButton *presentButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) DVEPopSelectView *popView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) id<DVECoreExportServiceProtocol> exportService;

@end

@implementation DVETopBar

DVEAutoInject(self.vcContext.serviceProvider, exportService, DVECoreExportServiceProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)buildLayout
{
    
    [self addSubview:self.saveButton];
    [self addSubview:self.fpsButton];
    [self addSubview:self.presentButton];
    
    _saveButton.right = VE_SCREEN_WIDTH - 12;
    _saveButton.top = 3;
    _saveButton.height = 28;
    _saveButton.width = 49;
    
    _presentButton.right = _saveButton.left - 30;
    _presentButton.centerY = _saveButton.centerY;
    
    _fpsButton.right = _presentButton.left - 40;
    _fpsButton.centerY = _saveButton.centerY;
    
    @weakify(self);
    [[_fpsButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self popFPS];
    }];
    [[_presentButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self popPresent];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)applicationEnterBackground {
    [self cancelExport];
}

- (void)popFPS
{
    @weakify(self);
    self.popView = [DVEPopSelectView showSelectInView:self.emptyView
                                               angleX:self.fpsButton.centerX
                                       withDataSource:[self.exportService exportFPSTitleArr]
                                   defaultSelectIndex:[DVEDataCache getExportFPSIndex]
                                         CompletBlock:^(NSInteger selectIndex) {
        @strongify(self);
        [self.exportService setExportFPSSelectIndex:selectIndex];
        [self.fpsButton setTitle:[self.exportService exportFPSTitleArr][[DVEDataCache getExportFPSIndex]] forState:UIControlStateNormal];
        [self dismissPopSelectView];
    }];
    self.tapGestureRecognizer.delegate = self.popView;
    [[DVEComponentViewManager sharedManager].parentView addSubview:self.emptyView];
}

- (void)popPresent
{
    @weakify(self);
    self.popView = [DVEPopSelectView showSelectInView:self.emptyView
                                               angleX:self.presentButton.centerX
                                       withDataSource:[self.exportService
                                                       exportPresentTitleArr]
                                   defaultSelectIndex:[DVEDataCache getExportPresentIndex]
                                         CompletBlock:^(NSInteger selectIndex) {
        @strongify(self);
        [self.exportService setExportPresentSelectIndex:selectIndex];
        [self.presentButton setTitle:[self.exportService exportPresentTitleArr][[DVEDataCache getExportPresentIndex]] forState:UIControlStateNormal];
        [self dismissPopSelectView];
    }];
    self.tapGestureRecognizer.delegate = self.popView;
    [[DVEComponentViewManager sharedManager].parentView addSubview:self.emptyView];
}

- (void)dismissPopSelectView {
    [self.popView removeFromSuperview];
    self.popView = nil;
    [self.emptyView removeFromSuperview];
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopSelectView)];
    }
    return _tapGestureRecognizer;
}
    
- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:[DVEComponentViewManager sharedManager].parentView.bounds];
        [_emptyView addGestureRecognizer:self.tapGestureRecognizer];
    }
    return _emptyView;
}


- (UIButton *)saveButton
{
    if (!_saveButton) {
        CGSize size = [DVEUILayout dve_sizeWithName:DVEUILayoutTopBarDoneButtonSize];
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _saveButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _saveButton.layer.backgroundColor = [UIColor dve_themeColor].CGColor;
        _saveButton.layer.cornerRadius = [DVEUILayout dve_sizeNumberWithName:DVEUILayoutButtonCornerRadius];
        _saveButton.layer.borderWidth = 1;
        _saveButton.clipsToBounds = YES;
        [_saveButton setBackgroundImage:@"bg_vevc_done".dve_toImage forState:UIControlStateNormal];
        _saveButton.titleLabel.textColor = [UIColor whiteColor];
        _saveButton.titleLabel.font = SCRegularFont(12);
        [_saveButton setTitle:NLELocalizedString(@"ck_done", @"完成")  forState:UIControlStateNormal];
        @weakify(self);
        [[_saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self save];
        }];
    }
    
    return _saveButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        @weakify(self);
        [[_cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self cancelExport];
        }];
    }
    
    return _cancelButton;
}

- (UIButton *)fpsButton
{
    if (!_fpsButton) {
        _fpsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
        _fpsButton.titleLabel.font = HelBoldFont(12);
        _fpsButton.titleLabel.textColor = [UIColor whiteColor];
        _fpsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _fpsButton;
}

- (UIButton *)presentButton
{
    if (!_presentButton) {
        _presentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 35)];
        _presentButton.titleLabel.font = HelBoldFont(12);
        _presentButton.titleLabel.textColor = [UIColor whiteColor];
        _presentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _presentButton;
}

- (void)setVcContext:(DVEVCContext *)vcContext
{
    [super setVcContext:vcContext];
    [_fpsButton setTitle:[self.exportService exportFPSTitleArr][[DVEDataCache getExportFPSIndex]] forState:UIControlStateNormal];
    [_presentButton setTitle:[self.exportService exportPresentTitleArr][[DVEDataCache getExportPresentIndex]] forState:UIControlStateNormal];
}

- (void)save
{
    [DVECustomerHUD showProgress];
    [DVECustomerHUD setProgressLableWithText:[NSString stringWithFormat:@"%@ %0.1f%%",NLELocalizedString(@"ck_video_synthesis", @"合成中"),0.0]];
    [self.superview addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superview);
    }];
    
    // save draft
    id<DVECoreDraftServiceProtocol> draftService = DVEAutoInline(self.vcContext.serviceProvider, DVECoreDraftServiceProtocol);
    DVEDraftModel *draftModel = draftService.draftModel;
    [draftService saveDraftModel:draftModel];
    
    //log export video event
    [DVEReportUtils logVideoExportClickEvent:self.vcContext];
    
    //禁止熄屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // export video
    @weakify(self);
    [self.exportService exportVideoWithProgress:^(CGFloat progress) {
        [DVECustomerHUD setProgressLableWithText:[NSString stringWithFormat:@"%@ %0.1f%%",NLELocalizedString(@"ck_video_synthesis", @"合成中"),progress]];
    } resultBlock:^(NSError * _Nonnull error, id  _Nonnull result) {
        @strongify(self);
        [DVECustomerHUD hidProgress];
        [self.cancelButton removeFromSuperview];
        
        if (error) {
            [DVEToast showInfo:@"合成失败"];
            [DVEReportUtils logVideoExportResultEvent:self.vcContext isSuccess:NO failCode:[NSString stringWithFormat:@"%ld", (long)error.code] failMsg:error.description];
            DVELogError(@"--------------export failed with:%@", error);
        } else  {
            [DVEToast showInfo:NLELocalizedString(@"ck_has_saved_local_and_draft", @"已保存到本地和草稿箱")];
            [DVEReportUtils logVideoExportResultEvent:self.vcContext isSuccess:YES failCode:nil failMsg:nil];
            id<DVEEditorEventProtocol> param = DVEOptionalInline(self.vcContext.serviceProvider, DVEEditorEventProtocol);
            
            if (param && [param respondsToSelector:@selector(editorDidExportedVideo:result:videoURL:draftID:)]) {
                [param editorDidExportedVideo:self.parentVC result:error ? NO : YES videoURL:result draftID:draftService.draftModel.draftID];
            } else {
                if (self.parentVC.presentationController) {
                    [self.parentVC dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.parentVC.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }];
    
}

- (void)cancelExport
{
    if(![DVEConfig dve_enableWithName:DVEConfigExportCancelEnable]){
        return;
    }
    [self.cancelButton removeFromSuperview];
    [self.exportService cancelExport];
    [DVECustomerHUD hidProgress];
    [DVEToast showInfo:@"合成取消"];
}

- (void)saveVideoToAlbum:(NSString *)path {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        [self saveVideoPath:path];
    } else {
        [self saveVideoPath:path];
    }
    
}

- (void)createFolder:(NSString *)folderName completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler
{
    if (![self isExistFolder:folderName]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //添加HUD文件夹
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:folderName];
            
        } completionHandler:completionHandler];
    } else {
        completionHandler(YES,nil);
    }
}

- (BOOL)isExistFolder:(NSString *)folderName {
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    __block BOOL isExisted = NO;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:folderName])  {
            isExisted = YES;
        }
    }];
    
    return isExisted;
}

- (void)saveVideoPath:(NSString *)videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    [self createFolder:@"VEDemo编辑" completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            //标识保存到系统相册中的标识
            __block NSString *localIdentifier;
            
            //首先获取相册的集合
            PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            //对获取到集合进行遍历
            [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAssetCollection *assetCollection = obj;
                //folderName是我们写入照片的相册
                if ([assetCollection.localizedTitle isEqualToString:@"VEDemo编辑"])  {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        //请求创建一个Asset
                        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                        //请求编辑相册
                        PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        //为Asset创建一个占位符，放到相册编辑请求中
                        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                        //相册中添加视频
                        [collectonRequest addAssets:@[placeHolder]];
                        
                        localIdentifier = placeHolder.localIdentifier;
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (success) {
                            
                            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_save_album_success", @"保存相册成功") afterDele:3];
                        } else {
                            NSLog(@"保存视频失败:%@", error);
                            [DVECustomerHUD showMessage:[NSString stringWithFormat:@"保存相册视频失败:%@",error.localizedDescription] afterDele:3];
                            
                        }
                    }];
                }
            }];
        } else {
            [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_create_workspace_failed",@"创建相册文件夹失败") afterDele:3];
        }
    }];
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error - %@", error);
        
        [DVECustomerHUD showMessage:[NSString stringWithFormat:@"%@:%@",@"保存相册失败",error.localizedDescription] afterDele:3];
    } else {
        NSLog(@"保存到相册成功");
        [DVECustomerHUD showMessage:NLELocalizedString(@"ck_tips_save_album_success", @"保存相册成功")  afterDele:3];
    }
}

@end
