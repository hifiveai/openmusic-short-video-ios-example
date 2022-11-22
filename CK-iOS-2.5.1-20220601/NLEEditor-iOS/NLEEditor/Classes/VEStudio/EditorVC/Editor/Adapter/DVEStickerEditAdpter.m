//
//  DVEStickerEditAdpter.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEStickerEditAdpter.h"
#import "DVEVCContext.h"
#import "DVETextParm.h"
#import "NSString+VEToImage.h"
#import "DVEMacros.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/CMTime+NLE.h>
#import <NLEPlatform/NLEEditor+iOS.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>
#import <DVETrackKit/DVECGUtilities.h>
#import "DVETextTemplateInputManager.h"
#import "DVEComponentViewManager.h"

@interface NSArray (Sticker)
- (BOOL)NLEConstainsSticker:(NSString *)segId;
- (BOOL)ItemContainsSticker:(NSString *)segId;

@end

@implementation NSArray (Sticker)

- (BOOL)NLEConstainsSticker:(NSString *)segId {
    BOOL contains = NO;
    for (NLETrackSlot_OC *item in self) {
        if ([item.nle_nodeId isEqualToString:segId]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

- (BOOL)ItemContainsSticker:(NSString *)segId {
    BOOL contains = NO;
    for (DVEEditItem *item in self) {
        if ([item.resourceId isEqualToString:segId]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

@end



@interface DVEStickerEditAdpter ()
<
DVETransformEditViewDelegate,
DVECoreActionNotifyProtocol,
DVEStickerKeyFrameProtocol
>

@property (nonatomic) DVETransformEditView *editStickerView;
@property (nonatomic) DVETransformEditView *editTextStickerView;
@property (nonatomic, strong) DVETransformEditViewConfig *boxconfig;
@property (nonatomic) DVETransformEditViewConfig *textBoxConfig;

@property (nonatomic) NSMutableArray <DVEEditItem *>*stickerItems;
@property (nonatomic, strong)NSMutableArray* tapEventList;

@property (nonatomic, weak) id<DVECoreTextTemplateProtocol> textTemplateEditor;
@property (nonatomic, weak) id<DVECoreStickerProtocol> stickerEditor;
@property (nonatomic, weak) id<DVECoreSlotProtocol> slotEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@property (nonatomic, assign) BOOL disableKeyframeCallBack;

@end

@implementation DVEStickerEditAdpter

DVEAutoInject(self.vcContext.serviceProvider, textTemplateEditor, DVECoreTextTemplateProtocol)
DVEAutoInject(self.vcContext.serviceProvider, stickerEditor, DVECoreStickerProtocol)
DVEAutoInject(self.vcContext.serviceProvider, slotEditor, DVECoreSlotProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stickerItems = [NSMutableArray array];
        _disableKeyframeCallBack = NO;
    }
    return self;
}

#pragma mark - Getter
- (DVETransformEditView *)editStickerView
{
    if (!_editStickerView) {
        DVETransformEditView *view = [[DVETransformEditView alloc] initWithConfig:self.boxconfig];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
        _editStickerView = view;
    }
    
    return _editStickerView;
}

- (DVETransformEditView *)editTextStickerView
{
    if (!_editTextStickerView) {
        DVETransformEditView *view = [[DVETransformEditView alloc] initWithConfig:self.textBoxConfig];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
        _editTextStickerView = view;
    }
    
    return _editTextStickerView;
}

- (DVETransformEditViewConfig *)boxconfig
{
    if (!_boxconfig) {
        DVEEditBoxConfig *boxconfig = [[DVEEditBoxConfig alloc] init];
        boxconfig.topLeft = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcCloseN".dve_toImage  highlightImage:@"textIcCloseP".dve_toImage type:DVECornrDelete];
        boxconfig.topRight = [[DVEEditBoxCornerInfo alloc] initWithImage:@"stickerIcMirrorN".dve_toImage  highlightImage:@"stickerIcMirrorN".dve_toImage type:DVECornerMirror];
        boxconfig.bottomLeft = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcCopyN".dve_toImage  highlightImage:@"textIcCopyN".dve_toImage type:DVECornerCopy];
        boxconfig.bottomRight = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcRorateN".dve_toImage  highlightImage:@"textIcRorateN".dve_toImage type:DVECornerPinch];
        boxconfig.pinchExpand = 3;
        
        DVETransformEditViewConfig *config = [[DVETransformEditViewConfig alloc] init];
        config.boxConfig = boxconfig;
        _boxconfig = config;
    }
    
    return _boxconfig;
}

- (DVETransformEditViewConfig *)textBoxConfig {
    if (!_textBoxConfig) {
        DVEEditBoxConfig *boxconfig = [[DVEEditBoxConfig alloc] init];
        boxconfig.topLeft = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcCloseN".dve_toImage  highlightImage:@"textIcCloseP".dve_toImage type:DVECornrDelete];
//        boxconfig.topRight = [[VEEditBoxCornerInfo alloc] initWithImage:@"stickerIcMirrorN".dve_toImage  highlightImage:@"textIcCloseP".dve_toImage type:DVECornerMirror];
        boxconfig.bottomLeft = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcCopyN".dve_toImage  highlightImage:@"textIcCopyN".dve_toImage type:DVECornerCopy];
        boxconfig.bottomRight = [[DVEEditBoxCornerInfo alloc] initWithImage:@"textIcRorateN".dve_toImage  highlightImage:@"textIcRorateN".dve_toImage type:DVECornerPinch];
        boxconfig.pinchExpand = 3;
        
        DVETransformEditViewConfig *config = [[DVETransformEditViewConfig alloc] init];
        config.boxConfig = boxconfig;
        _textBoxConfig = config;
    }
    return _textBoxConfig;
}

- (NSMutableArray *)tapEventList {
    if(!_tapEventList){
        _tapEventList = [NSMutableArray array];
    }
    return _tapEventList;
}

#pragma mark - Setter

- (void)setVcContext:(DVEVCContext *)vcContext {
    if(_vcContext == vcContext) return;
    _vcContext = vcContext;
    [DVEAutoInline(_vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
    self.stickerEditor.keyFrameDelegate = self;
}

- (void)undoRedoWillClikeByUser
{
    
}

- (void)undoRedoClikedByUser
{
    [self refreshCurrentItems];
}

- (void)refreshCurrentItems
{
    switch (self.curType) {
        case VEVCStickerEditTypeTextTemplate:
        case VEVCStickerEditTypeText:
        {
            ///文本和文字模板都在同一个editView，所以统一刷新
            NSMutableArray* array = [NSMutableArray arrayWithArray:self.stickerEditor.textSlots];
            [array addObjectsFromArray:self.textTemplateEditor.textTemplatestickerSlots];
            [self refreshItems:array];
        }break;
        case VEVCStickerEditTypeSticker:
        {
            [self refreshItems:[self.stickerEditor.stickerSlots copy]];
        }break;
        default:{}
    }
}

#pragma mark - Public
- (void)showInPreview:(UIView *)view  withType:(VEVCStickerEditType)type
{
    self.curType = type;
    switch (type) {
        case VEVCStickerEditTypeText:
        case VEVCStickerEditTypeTextTemplate:
        { 
            self.editView = self.editTextStickerView;
            NSMutableArray* array = [NSMutableArray arrayWithArray:self.stickerEditor.textSlots];
            [array addObjectsFromArray:self.textTemplateEditor.textTemplatestickerSlots];
            [self refreshItems:array];
        }break;
        case VEVCStickerEditTypeSticker:{
            self.editView = self.editStickerView;
            [self refreshItems:self.stickerEditor.stickerSlots];
        }break;
        default: {
            return;
        }
    }
    [view addSubview:self.editView];
    self.editView.frame = view.bounds;
    
    ///当保存带有贴纸，文本，文字模板素材的草稿后，再次打开草稿并进入编辑模块时，
    ///edittView里的Items是空的，因为恢复草稿的时候，并不会像首次添加素材时调用addEditItems，
    ///所以这里需要refreshItems，不然就会出现预览区域没有白色编辑框
    [self refreshCurrentItems];
}

- (void)hideFromPreview{
    [self.editView removeFromSuperview];
    self.editView = nil;
    self.curType = VEVCStickerEditTypeNone;
}

- (void)refreshItems:(NSArray *)slots {
    
    NSMutableArray *removedIds = [NSMutableArray array];
    for (DVEEditItem *item in self.stickerItems) {
        [removedIds addObject:item.resourceId];
    }
    if (removedIds.count) {
        [self.editView removeEditItems:removedIds];
    }
    [self.stickerItems removeAllObjects];
    
    [slots enumerateObjectsUsingBlock:^(NLETrackSlot_OC *slot, NSUInteger idx, BOOL * _Nonnull stop) {
        DVEEditItem *item = [self createEditItemForSlot:slot];
        [self.stickerItems addObject:item];
        if (item) {
            [self updateItemSize:item];
            [self.editView addEditItems:@[item]];
        }
    }];
    
}

/// 替换 items
/// 与 `refreshItems:` 区别：
/// 此方法只替换 slots 对应的 items，而 `refreshItems:` 会把所有 items 都删除后，再添加
- (void)replaceItemsWithSlots:(NSArray *)slots {
    NSMutableArray *removedIds = [NSMutableArray array];
    NSMutableArray *removedItems = [NSMutableArray array];
    for (DVEEditItem *item in self.stickerItems) {
        for (NLETrackSlot_OC *slot in slots) {
            if ([slot.nle_nodeId isEqualToString:item.resourceId]) {
                [removedIds addObject:item.resourceId];
                [removedItems addObject:item];
            }
        }
    }
    
    if (removedIds.count) {
        [self.editView removeEditItems:removedIds];
        [self.stickerItems removeObjectsInArray:removedItems];
    }
    
    [slots enumerateObjectsUsingBlock:^(NLETrackSlot_OC *slot, NSUInteger idx, BOOL * _Nonnull stop) {
        DVEEditItem *item = [self createEditItemForSlot:slot];
        [self.stickerItems addObject:item];
        if (item) {
            [self updateItemSize:item];
            [self.editView addEditItems:@[item]];
        }
    }];
}

- (void)updateSubElementWithItem:(DVEEditItem *)item {
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:item.resourceId];
    item.borderElements = [self createBorderElementsWithSlot:slot];
}


- (void)refreshEditBox:(nullable NSString *)segmentId {
    @weakify(self);
    [self.editView updateEditItem:segmentId updater:^(DVEEditItem * _Nonnull item) {
        @strongify(self);
        NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:item.resourceId];
        if (!slot) {
            slot = [self.nleEditor.nleModel.coverModel slotOf:item.resourceId];
        }
        CGSize normaliz = [self originEditItemSizeForSlot:slot slotScale:slot.scale];
        item.size = normaliz;
    }];
}

- (void)addEditBoxForSticker:(NSString *)segmentId{
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:segmentId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    DVEEditItem *item = [self createEditItemForSlot:slot];
    
    [self.stickerItems addObjectsFromArray:@[item]];
    [self.editView addEditItems:@[item]];
    [self.editView activeEditItem:item.resourceId];
}

- (void)addEditBoxForStickerWithVideoCover:(NLEVideoFrameModel_OC *)coverModel
                                 segmentId:(NSString *)segmentId {
    NLETrackSlot_OC *slot = [coverModel slotOf:segmentId];
    DVEEditItem *item = [self createEditItemForSlot:slot];
    
    [self.stickerItems addObjectsFromArray:@[item]];
    [self.editView addEditItems:@[item]];
    [self.editView activeEditItem:item.resourceId];
}

- (void)removeStickerBox:(NSString *)segmentId {

    [self.editView removeEditItems:@[segmentId]];
    [self removeItems:@[segmentId]];
}

- (void)changeSelectTextSlot:(NSString *)segmentId {
    if (segmentId) {
        NLETrackSlot_OC *slot = nil;
        if (self.nleEditor.nleModel.coverModel.enable) {
            slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
        } else {
            NLEModel_OC *model = self.nleEditor.nleModel;
            slot = [model slotOf:segmentId];
        }
        self.vcContext.mediaContext.selectTextSlot = slot;
        // 当textBar显示时，选中不同文本，需更新
        if([self.delegate respondsToSelector:@selector(changeSelectTextSlot:)]){
            [self.delegate changeSelectTextSlot:segmentId];
        }
    } else {
        self.vcContext.mediaContext.selectTextSlot = nil;
    }
}


#pragma mark - Private


- (void)activeEditBox:(NSString *)segmentId {
    if (segmentId) {
        [self moveElementToTop:segmentId];
        [self.editView activeEditItem:segmentId];
        [self changeSelectTextSlot:segmentId];
    } else {
        [self.editView activeEditItem:nil];
    }
}

- (void)updateItemSize:(DVEEditItem *)item {
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:item.resourceId];
    if(!slot) return;

    CGSize stickerSize = [self originEditItemSizeForSlot:slot slotScale:slot.scale];
    CGSize visibleSize = self.editView.bounds.size;
    
    CGFloat offsetX = visibleSize.width * 0.5 * (1 + slot.transformX);
    CGFloat offsetY = visibleSize.height * 0.5 * (1 - slot.transformY);
    
    [self updateBorderElementsSizeWithItem:item];
    item.transform.scale = slot.scale;
    item.transform.translation = CGPointMake(offsetX, offsetY);
    item.transform.rotation  = -slot.rotation * M_PI / 180;
    DVELogInfo(@"ad transform size:%@ scale:%f trans:%@ rota:%f",NSStringFromCGSize(stickerSize),slot.scale,NSStringFromCGPoint(item.transform.translation),item.transform.rotation);
    item.size = stickerSize;
}

- (void)updateBorderElementsSizeWithItem:(DVEEditItem *)item {
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:item.resourceId];
    if ([slot.segment getType] != NLEResourceTypeTextTemplate) {
        return;
    }
    
    NLETextTemplateInfo *textInfo = [self.nle textTemplateInfoForSlot:slot];
    if (!textInfo) {
        [item.borderElements enumerateObjectsUsingBlock:^(DVEEditItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.size = CGSizeZero;
            obj.transform.scale = 0;
            obj.transform.translation = CGPointZero;
            obj.transform.rotation = 0;
        }];
        return;
    }
    float scale = slot.scale;
    CGSize visibleSize = self.editView.bounds.size;
    
    [textInfo.textInfos enumerateObjectsUsingBlock:^(NLETextTemplateSubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize size = [self originEditItemSizeWithNormalSize:obj.normalizSize slotScale:scale];
        CGPoint translation = obj.translation;
        
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            float rotation = -slot.rotation * M_PI / 180.0;
            CGFloat x = translation.x;
            CGFloat y = translation.y;
            CGFloat offsetX = visibleSize.width * 0.5 * (1 + x);
            CGFloat offsetY = visibleSize.height * 0.5 * (1 - y);
            if (idx < item.borderElements.count) {
                DVEEditItem *i = item.borderElements[idx];
                i.size = size;
                i.transform.scale = scale;
                i.transform.rotation = rotation;
                i.transform.translation = CGPointMake(offsetX, offsetY);
            }
        }
    }];
}

- (CGSize)originEditItemSizeForSlot:(NLETrackSlot_OC *)slot  slotScale:(float)scale
{
    CGSize normaliz = CGSizeZero;
    switch (slot.segment.getType) {
        case NLEResourceTypeTextTemplate:
        {
            NLETextTemplateInfo *textInfo = [self.nle textTemplateInfoForSlot:slot];
            normaliz = textInfo.normalizSize;
        }
            break;
        default:
        {
            NSInteger veStickerId = [self.nle stickerIdForSlot:slot.nle_nodeId];
            normaliz = [self.nle getstickerEditBoxSizeNormaliz:veStickerId];
        }
            break;
    }
    
    return [self originEditItemSizeWithNormalSize:normaliz
                                        slotScale:scale];
}

- (CGSize)originEditItemSizeWithNormalSize:(CGSize)normaliz  slotScale:(float)scale {
    normaliz = CGSizeMake(normaliz.width / scale, normaliz.height / scale);

    CGSize visibleSize = self.editView.bounds.size;
    
    DVELogInfo(@"ve.size:%@",NSStringFromCGSize(normaliz));
    CGFloat stickerW = visibleSize.width * normaliz.width * 0.5;
    CGFloat stickerH = visibleSize.height * normaliz.height * 0.5;
    DVELogInfo(@"sitcker edit size:%f,%f",stickerW,stickerH);
    return CGSizeMake(stickerW, stickerH);
}


- (DVEEditItem *)createEditItemForSlot:(NLETrackSlot_OC *)slot {
    if (!slot) {
        return  nil;
    }
    NSInteger stickerId = [self.nle stickerIdForSlot:slot.nle_nodeId];
    CGSize sticerSize = [self originEditItemSizeForSlot:slot slotScale:slot.scale];
    DVEEditItem *item = [[DVEEditItem alloc] initWithStickerId:stickerId resourceId:slot.nle_nodeId size:sticerSize order:0];
    [self updateEditItem:item forSlot:slot];
    return item;
}

-(void)updateEditItem:(DVEEditItem *)item forSlot:(NLETrackSlot_OC *)slot {
    CGSize visibleSize = self.editView.bounds.size;
    CGFloat x = slot.transformX;
    CGFloat y = slot.transformY;
    CGFloat offsetX = visibleSize.width * 0.5 * (1 + x);
    CGFloat offsetY = visibleSize.height * 0.5 * (1 - y);
    DVEEditTransform *transform = [[DVEEditTransform alloc] init];
    transform.translation =  CGPointMake(offsetX, offsetY);
    transform.rotation = -slot.rotation * M_PI / 180;
    transform.scale = slot.scale ;
    item.transform = transform;
    
    if (slot.segment.getType == NLEResourceTypeTextSticker) {
        item.boxSizeScale = 1.15;
        item.minScale = 0.001;
        item.maxScale = 200;
    } else {
        item.minScale = 0.25;
        item.maxScale = 5.0;
    }
    // 添加文本模板里的多段文字信息
    if (slot.segment.getType == NLEResourceTypeTextTemplate) {
        item.borderElements = [self createBorderElementsWithSlot:slot];
    }
}

- (NSArray *)createBorderElementsWithSlot:(NLETrackSlot_OC *)slot {
    NSMutableArray *elements = [NSMutableArray new];
    NLESegment_OC *segment = slot.segment;
    if (!segment || [segment getType] != NLEResourceTypeTextTemplate) {
        return elements;
    }
    
    float scale = slot.scale;
    NLETextTemplateInfo *textInfo = [self.nle textTemplateInfoForSlot:slot];
    [textInfo.textInfos enumerateObjectsUsingBlock:^(NLETextTemplateSubInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGSize elementSize = [self originEditItemSizeWithNormalSize:obj.normalizSize slotScale:scale];
        CGSize visibleSize = self.editView.bounds.size;
        CGPoint translation = obj.translation;
        
        if (!CGSizeEqualToSize(elementSize, CGSizeZero)) {
            DVEEditItem *e = [[DVEEditItem alloc] initWithStickerId:segment.getID resourceId:[NSString stringWithFormat:@"%lu", (unsigned long)obj.index] size:elementSize order:0];
            // note(caishaowu):与updateBorderElementsSizeWithItem:中类似
            // 确定位置
            float rotation = -slot.rotation * M_PI / 180.0;
            CGFloat x = translation.x;
            CGFloat y = translation.y;
            CGFloat offsetX = visibleSize.width * 0.5 * (1 + x);
            CGFloat offsetY = visibleSize.height * 0.5 * (1 - y);
            e.transform.translation = CGPointMake(offsetX, offsetY);
            e.transform.rotation = rotation;
            e.transform.scale = slot.scale;
            
            [elements addObject:e];
        }
    }];
    
    return elements;
}

- (void)moveElementToTop:(NSString *)segmentId {
    // items最大order + 2
    [self.editView updateEditItems:^(NSArray<DVEEditItem *> * _Nonnull items) {
        int maxOrder = 0;
        DVEEditItem *hitItem = nil;
        for (DVEEditItem *item in items) {
            if (maxOrder < item.order) {
                maxOrder = item.order;
            }
            if ([item.resourceId isEqualToString:segmentId]) {
                hitItem = item;
            }
        }
        if (hitItem) {
            hitItem.order = maxOrder + 2;
        }

        [self.nle setStickerLayer:hitItem.stikerId layer:hitItem.order];
    }];
    
}

- (void)removeItems:(NSArray <NSString *>*)segIds {
    [self.editView removeEditItems:segIds];
    [self.stickerItems enumerateObjectsUsingBlock:^(DVEEditItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([segIds containsObject:obj.resourceId]) {
            [self.stickerItems removeObject:obj];
        }
    }];
}

- (BOOL)isCurrentTimeStampOutOfItemTimeRange:(DVEEditItem *)item
{
    CMTime current = self.vcContext.mediaContext.currentTime;
    NLETrackSlot_OC *slot = item ? [self.nleEditor.nleModel slotOf:item.resourceId] : nil;
    if (slot && !NLE_CMTimeRangeContain(slot.nle_targetTimeRange, current)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - VETransformEditViewDelegate

- (void)transformView:(DVETransformEditView *)editView didUpdateTransform:(DVEEditItem *)item {
    /* 角度
     - sticker: 顺时针，一周是 2π （6.28）
     - VE: 顺时针，一周为360
     */
    
    /* 归一化坐标
     - sticker: 左上角为原点
     - VE: 中心为原点
     */
    
    CGPoint center = item.transform.translation;
    CGFloat offsetX = (center.x - self.editView.frame.size.width * 0.5) / (self.editView.frame.size.width * 0.5);
    CGFloat offsetY = (self.editView.frame.size.height * 0.5 - center.y) /
    (self.editView.frame.size.height * 0.5);
    CGFloat angle =  item.transform.rotation * 180 / M_PI;
    CGFloat scale = item.transform.scale;
    [self.stickerEditor setSticker:item.resourceId offsetX:offsetX offsetY:offsetY angle:angle scale:scale isCommitNLE:NO];
    [self.vcContext.playerService seekToTime:self.vcContext.mediaContext.currentTime
                                    isSmooth:YES];
    // note(caishaowu): 更新item中位置相关信息，在DVETransformEditView中，会据此修改「虚线框」
    [self updateItemSize:item];
}


- (void)transformView:(DVETransformEditView *)editView beginTransform:(DVEEditItem *)item{
    self.disableKeyframeCallBack = YES;
}

- (void)transformView:(DVETransformEditView *)editView endTransform:(DVEEditItem *)item {
    self.disableKeyframeCallBack = NO;
    CGPoint center = item.transform.translation;
    CGFloat offsetX = (center.x - self.editView.frame.size.width * 0.5) / (self.editView.frame.size.width * 0.5);
    CGFloat offsetY = (self.editView.frame.size.height * 0.5 - center.y) /
    (self.editView.frame.size.height * 0.5);
    CGFloat angle =  item.transform.rotation * 180 / M_PI;
    CGFloat scale = item.transform.scale;
    DVELogInfo(@"sticker box angle:%f,scale:%f,offset:%@,size:%@",item.transform.rotation,item.transform.scale,NSStringFromCGPoint(center),NSStringFromCGSize(item.size));
    if([self.delegate respondsToSelector:@selector(stickerTransform:offsetX:offsetY:angle:scale:)]){
        if([self.delegate stickerTransform:item.resourceId offsetX:offsetX offsetY:offsetY angle:angle scale:scale]){
            return;
        }
    }
    [self.stickerEditor setSticker:item.resourceId offsetX:offsetX offsetY:offsetY angle:angle scale:scale isCommitNLE:YES];
}

- (void)transformView:(DVETransformEditView *)editView didTapBoxView:(UITapGestureRecognizer *)tap item:(DVEEditItem *)item {
    if ([self isCurrentTimeStampOutOfItemTimeRange:item]) {
        [self transformView:editView outTapBoxView:tap];
        return;
    }
    
    [self activeEditBox:item.resourceId];
    [self changeSelectTextSlot:item.resourceId];
    // 点击空白区域，隐藏输入框
    [[DVETextTemplateInputManager sharedInstance] dismiss];
    //与outTapBoxView对应，当找到响应item，则需要清空队列
    [self.tapEventList removeAllObjects];
}

- (void)transformView:(DVETransformEditView *)editView didTapBorderView:(DVEEditItem *)item {
    if (_curType == VEVCStickerEditTypeTextTemplate) {
        if (item) {
            NSUInteger index = item.resourceId.integerValue;
            [[DVETextTemplateInputManager sharedInstance] showWithTextIndex:index
                                                                     source:DVETextTemplateInputManagerSourceEditBox];
        }
    }
    //与outTapBoxView对应，当找到响应item，则需要清空队列
    [self.tapEventList removeAllObjects];
}

- (void)transformView:(DVETransformEditView *)editView didTriggerAction:(DVEEditCornerType)type item:(DVEEditItem *)item {
    if([self.delegate respondsToSelector:@selector(triggerAction:segmentId:)]){
        if([self.delegate triggerAction:type segmentId:item.resourceId]) return;
    }
    
    if (type == DVECornrDelete) {
        [self removeStickerBox:item.resourceId];
        if (_curType == VEVCStickerEditTypeTextTemplate) {
            [self.textTemplateEditor removeTextTemplate:item.resourceId isCommit:YES];
            // 点击删除，隐藏输入框
            [[DVETextTemplateInputManager sharedInstance] dismiss];
        } else {
            NSString *segmentId = item.resourceId;
            NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:segmentId];
            BOOL mainEdit = slot ? YES : NO;
            if (!slot) {
                slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
            }

            [self.slotEditor removeSlot:item.resourceId needCommit:YES isMainEdit:mainEdit];
            
            if (_curType == VEVCStickerEditTypeText) {
                // 关闭 textbar
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeText];
            }
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
        }
    } else if(type == DVECornerMirror) {
        [self.stickerEditor setStickerFilpX:item.resourceId];
    } else if (type == DVECornerCopy) {
        if (_curType == VEVCStickerEditTypeTextTemplate) {
            [self.textTemplateEditor copyTextTemplateWithIsCommit:YES];
        } else {
            [self.slotEditor copyForSlot:item.resourceId needCommit:YES];
        }
        [self refreshEditBox:item.resourceId];
    }
}


- (void)transformView:(DVETransformEditView *)editView didDoubleTapBoxView:(UITapGestureRecognizer *)tap item:(DVEEditItem *)item {
    if ([self isCurrentTimeStampOutOfItemTimeRange:item]) {
        [self transformView:editView outTapBoxView:tap];
        return;
    }
    
    [self activeEditBox:item.resourceId];
    [self changeSelectTextSlot:item.resourceId];
    if([self.delegate respondsToSelector:@selector(doubleClick:)]){
        [self.delegate doubleClick:item.resourceId];
    }
}

- (void)transformView:(DVETransformEditView *)editView outTapBoxView:(UITapGestureRecognizer *)tap {
    
    if(self.tapEventList.count == 0){
        ///为了防止无限传递空点击事件，这里需要在最开始触发空点回调的时候，记录所有未消费的DVETransformEditView对象
        ///首先记录当前触发的editView
        //这块预览架构得重构 TODo
        [self.tapEventList addObject:editView];
    }
    
    if(![self.tapEventList containsObject:self.editStickerView] && [self.editStickerView numberOfItems] > 0){
        [self.tapEventList addObject:self.editStickerView];
        UIView* superview = editView.superview;
        [self.editView activeEditItem:nil];
        [self hideFromPreview];
        [self showInPreview:superview withType:VEVCStickerEditTypeSticker];
        [self.editView tapOnCanvas:tap];
    }else if(![self.tapEventList containsObject:self.editTextStickerView] && [self.editTextStickerView numberOfItems] > 0){
        [self.tapEventList addObject:self.editTextStickerView];
        UIView* superview = editView.superview;
        [self.editView activeEditItem:nil];
        [self hideFromPreview];
        [self showInPreview:superview withType:VEVCStickerEditTypeText];
        [self.editView tapOnCanvas:tap];
    }else{
        DVETransformEditView* firstEdit = self.tapEventList.firstObject;
        UIView* superview = firstEdit.superview;
        
        [self transformView:nil didTapBoxView:nil item:nil];
        ///上面transformView会导致hideFromPreview，这样会使“添加贴纸/文本/文字模板”状态下，在预览区域无法再点击editView
        ///所以这里要根据点击事件链tapEventList，重现展示第一个触发点击事件链的editView
        if(firstEdit == self.editStickerView){
            [self showInPreview:superview withType:VEVCStickerEditTypeSticker];
        }else if(firstEdit == self.editTextStickerView){
            [self showInPreview:superview withType:VEVCStickerEditTypeText];
        }
    }
}

#pragma mark - DVEStickerKeyFrameDelegate
- (void)stickerKeyFrameDidChangedWithSlot:(NLETrackSlot_OC *)slot {
    if (self.disableKeyframeCallBack || !slot || [slot getKeyframe].count <= 0) {
        return;
    }
    
    if (CMTimeCompare(slot.startTime, self.vcContext.mediaContext.currentTime) > 0 ||
        CMTimeCompare(slot.endTime, self.vcContext.mediaContext.currentTime) < 0) {
        return;
    }
    
    for (DVEEditItem *item in self.stickerItems) {
        if ([item.resourceId isEqualToString:slot.nle_nodeId]) {
            [self updateEditItem:item forSlot:slot];
            break;
        }
    }
    [self refreshEditBox:slot.nle_nodeId];
}

@end
