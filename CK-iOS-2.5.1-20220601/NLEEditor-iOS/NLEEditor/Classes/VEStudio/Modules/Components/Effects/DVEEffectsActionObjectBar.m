//
//   DVEEffectsActionObjectBar.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/19.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEEffectsActionObjectBar.h"
#import "DVEEffectsBarBottomView.h"
#import "DVEEffectsItemCell.h"
#import "DVEVCContext.h"
#import "DVEBundleLoader.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "UIImage+DVE.h"
#import <Masonry/Masonry.h>

@interface DVEEffectsActionObjectBar()<UICollectionViewDelegate,UICollectionViewDataSource>

///对象区域
@property (nonatomic, strong) UICollectionView *objectPickerView;
///底部区域
@property (nonatomic, strong) DVEEffectsBarBottomView *bottomView;
///数据源
@property (nonatomic, strong) NSMutableArray *dataSource;
///特效唯一ID
@property (nonatomic, copy) NSString *effectObjID;
///当前特效作用slot索引
@property (nonatomic, assign) NSInteger currentIndex;
///是否可选择
@property (nonatomic, assign) BOOL enable;

@property (nonatomic, weak) id<DVECoreEffectProtocol> effectEditor;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEEffectsActionObjectBar

DVEAutoInject(self.vcContext.serviceProvider, effectEditor, DVECoreEffectProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}

#pragma mark - private Method

- (void)initView
{
    [self addSubview:self.objectPickerView];
    [self.objectPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(138);
        make.top.left.right.equalTo(self);
    }];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.objectPickerView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)initData
{
    self.enable = YES;
    self.currentIndex = -1;
    NLEModel_OC *model = self.nleEditor.nleModel;
    NLETimeSpaceNode_OC *timespaceNode = self.vcContext.mediaContext.selectEffectSegment;
    if ([timespaceNode isKindOfClass:NLETrackSlot_OC.class]) {
        NLETrackSlot_OC* selectedSlot = (NLETrackSlot_OC *)timespaceNode;
        NLESegmentEffect_OC* seg =  (NLESegmentEffect_OC*)selectedSlot.segment;
        NLEResourceNode_OC *resEffect = seg.effectSDKEffect;
        NLETrack_OC* track = [model trackContainSlotId:selectedSlot.nle_nodeId];
        self.effectObjID = resEffect.nle_nodeId;
        if([track getTrackType] == NLETrackEFFECT){///全局特效
            self.currentIndex = 0;
        }else{//局部特效

        }
    }
    
    ///插入“全局”特效数据
    NSString *name = NLELocalizedString(@"ck_global", @"全局");
    [self.dataSource addObject:@{
        @"name":name?:@"",
        @"image":@"icon_full_selection".dve_toImage,
    }];
    if(!self.effectObjID) return;
    

    //初始化局部特效数据
    
    CMTime currentTime = self.vcContext.mediaContext.currentTime;
    CMTimeRange effectTime = timespaceNode.nle_targetTimeRange;
    self.enable = CMTimeRangeContainsTime(effectTime, currentTime);//如果当前时间尺不在特效范围内，则不可点击
    for( NLETrack_OC* track in [model nle_allTracksOfType:NLETrackVIDEO]){
        for(NLETrackSlot_OC* s in [track slots]){
            //现在暂时以视频片段时间范围包含当前时间尺，并且特效时间范围包含时间片段或者特效起始/结束时间点在视频片段范围内为可作用对象依据
            if(CMTimeRangeContainsTime(s.nle_targetTimeRange, currentTime) &&(CMTimeRangeContainsTimeRange(effectTime, s.nle_targetTimeRange) ||   CMTimeRangeContainsTime(s.nle_targetTimeRange, effectTime.start) ||  CMTimeRangeContainsTime(s.nle_targetTimeRange, CMTimeRangeGetEnd(effectTime)))){
                UIImage* image = nil;
                if([s.segment getType] == NLEResourceTypeVideo){
                    AVAsset* asset = [self.nle assetFromSlot:s];
                    if(asset){
                        NSArray* videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo];
                        if(videoTrack.count > 0){
                            CGSize assetSize = [[videoTrack objectAtIndex:0] naturalSize];
                            CGSize thumbSize = [self calculThumbFrom:assetSize];
                            image = [UIImage dev_image:asset maxSize:thumbSize time:CMTimeMake(1.0, 600)];
                        }
                    }
                }else if([s.segment getType] == NLEResourceTypeImage){
                    NSString* path = [self.nle getAbsolutePathWithResource:s.segment.getResNode];
                    UIImage* orgImage = [UIImage imageWithContentsOfFile:path];
                    CGSize thumbSize = [self calculThumbFrom:orgImage.size];
                    image = [orgImage reSizeImage:thumbSize];
                }
                if(!image){
                    
                    image = [UIImage dev_image:[UIColor blackColor] size:[self collectionView:self.objectPickerView layout:self.objectPickerView.collectionViewLayout sizeForItemAtIndexPath:nil]];
                }
                NSString *mainTrack = NLELocalizedString(@"ck_main_track_video", @"主视频");
                NSString *pipTrack = NLELocalizedString(@"ck_pip", @"画中画");
                NSString *name = track.isMainTrack ? mainTrack:pipTrack;///目前只有主轨道上的视频和副轨道的画中画功能有视频slot
                [self.dataSource addObject:@{
                    @"name":name?:@"",
                    @"image":image,
                    @"slot":s,
                }];
                
                //如果currentIndex=0则已作用全局
                if(self.currentIndex < 0){
                    for(NLETrackSlot_OC *effect in [track getEffect]){
                        if([effect.nle_nodeId isEqualToString:timespaceNode.nle_nodeId]){
                            self.currentIndex = self.dataSource.count - 1;break;
                        }
                    }
                }
                break;
            }
        }
    }
    if(self.currentIndex < 0){
        self.enable = NO;
    }
    [self.objectPickerView reloadData];
}

-(void)showInView:(UIView *)view animation:(BOOL)animation{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
}

#pragma mark - lazy Method

- (UICollectionView *)objectPickerView
{
    if (!_objectPickerView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
        _objectPickerView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _objectPickerView.showsHorizontalScrollIndicator = NO;
        _objectPickerView.showsVerticalScrollIndicator = NO;
        _objectPickerView.delegate = self;
        _objectPickerView.dataSource = self;
        _objectPickerView.backgroundColor = HEXRGBCOLOR(0x181718);
        _objectPickerView.allowsMultipleSelection = NO;
        
        [_objectPickerView registerClass:[DVEEffectsItemCell class] forCellWithReuseIdentifier:NSStringFromClass(DVEEffectsItemCell.class)];
    }
    
    return _objectPickerView;
}

- (DVEEffectsBarBottomView*)bottomView
{
    if(!_bottomView) {
        @weakify(self);
        _bottomView = [DVEEffectsBarBottomView newActionBarWithTitle:NLELocalizedString(@"ck_applied_range", @"作用对象") action:^{
            @strongify(self);

            [self dismiss:YES];
            [DVEAutoInline(self.vcContext.serviceProvider, DVECoreActionServiceProtocol) refreshUndoRedo];
        }];
    }
    return _bottomView;
}

-(NSMutableArray *)dataSource {
    if(!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark -- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
    
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DVEEffectsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DVEEffectsItemCell.class) forIndexPath:indexPath];
    cell.style = DVEEffectsItemImageBottom;
    cell.font = SCRegularFont(12);
    
    NSDictionary* dic = self.dataSource[indexPath.item];
    [cell setTitleText:dic[@"name"]];
    [cell setImage:dic[@"image"]];
    cell.enable = self.enable;
    cell.imageMode = UIViewContentModeScaleAspectFill;
    [cell setStickerSelected:indexPath.item == self.currentIndex animated:NO];
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(56, 77);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(32, 14, 29,14);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}


#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.currentIndex || !self.enable || self.currentIndex < 0) return;
    NSDictionary* target = self.dataSource[indexPath.item];
    NSDictionary* org = self.dataSource[self.currentIndex];
    NLETrackSlot_OC* toSlot = target[@"slot"];
    NLETrackSlot_OC* fromSlot = org[@"slot"];
    
    if (indexPath.item == 0){
        ///从对应局部特效slot里移除effect
        [self.effectEditor movePartlyEffectToGlobal:self.effectObjID fromSlot:fromSlot];
    } else {
        if (self.currentIndex == 0){//把全局特效移动到局部特效
            [self.effectEditor moveGlobalEffectToPartly:((NLETrackSlot_OC*)self.vcContext.mediaContext.selectEffectSegment) partlySlot:toSlot];
        } else {///局部特效移动到其他局部特效Slot
            [self.effectEditor movePartlyEffectToOtherPartly:self.effectObjID fromSlot:fromSlot toSlot:toSlot];
        }
    }
    self.currentIndex = indexPath.item;
    [collectionView reloadData];
    NLETrackSlot_OC* targetSlot = [self.effectEditor slotByeffectObjID:self.effectObjID];
    self.vcContext.mediaContext.selectEffectSegment = targetSlot;
    if(targetSlot){
        [self.vcContext.playerService playFrom:targetSlot.startTime
                                    duration:CMTimeGetSeconds(targetSlot.duration)
                               completeBlock:nil];
    }
}


#pragma mark - Private


- (NSArray*)slotsAtTimeRange:(CMTimeRange)timeRange {
    NLEModel_OC *model = self.nleEditor.nleModel;
    NSMutableArray<NLETrackSlot_OC *> *slots = [NSMutableArray array];
    NSArray<NLETrack_OC *> *tracks = [model nle_allTracksOfType:NLETrackVIDEO];
    for (NLETrack_OC *track in tracks) {
        NSArray<NLETrackSlot_OC*> *slotArray = [track slots];
        for(NLETrackSlot_OC* s in slotArray){
            CMTimeRange range = CMTimeRangeGetIntersection(timeRange, s.nle_targetTimeRange);
            if(CMTIMERANGE_IS_VALID(range) && !CMTIMERANGE_IS_EMPTY(range)){
                [slots addObject:s];
            }
        }
    }
    return slots;
}

- (CGSize)calculThumbFrom:(CGSize)assetSize{
    
    CGFloat size = [self collectionView:self.objectPickerView layout:self.objectPickerView.collectionViewLayout sizeForItemAtIndexPath:nil].width * 1.5;//显示有点模糊，尺寸适当放大0.5倍
    CGSize maxSize;
    ///根据视频宽高比生成缩略图
    if(assetSize.height > assetSize.width){//竖屏
        maxSize = CGSizeMake(size, assetSize.height*size/assetSize.width);
    }else{//横屏
        maxSize = CGSizeMake(assetSize.width*size/assetSize.height, size);
    }

    return maxSize;

}

@end
