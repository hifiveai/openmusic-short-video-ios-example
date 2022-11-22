//
//  VECPTopBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPTopBar.h"
#import "VEBarValue.h"

@interface VECPTopBar ()

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) VEBarValue *timeValue;
@property (nonatomic, strong) VEBarValue *lightValue;
@property (nonatomic, strong) VEBarValue *ratioValue;
@property (nonatomic, strong) VEBarValue *resulotionValue;
@property (nonatomic, strong) VEBarValue *camareValue;

@end

@implementation VECPTopBar
@synthesize viewType = _viewType;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:[UIScrollView new] ];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collecView.frame = CGRectMake(55, VECPBaseBarSubViewTop,  self.width, VECPBaseBarSubViewH);
        [self.collecView reloadData];
        [self addSubview:self.closeButton];
        
    }
    
    return self;
}

- (void)buildLayout
{
    self.timeValue = [VEBarValue valueWithImages:
                      @[
                          @"icon_topbar_time".UI_VEToImage,
                          @"icon_topbar_time3".UI_VEToImage,
                          @"icon_topbar_time7".UI_VEToImage,
                      ]
                      eventCallType:VEEventCallCaptureTimeType
                      ];
    self.lightValue = [VEBarValue valueWithImages:
                       @[
                           
                           @"icon_topbar_flashoff".UI_VEToImage,
                           @"icon_topbar_flashon".UI_VEToImage,
                       ]
                       eventCallType:VEEventCallLightState
                       ];
    self.ratioValue = [VEBarValue valueWithTitles:@[@"9:16",@"3:4",@"1:1",@"4:3",@"16:9"] eventCallType:VEEventCallRatioType];
    if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
        self.ratioValue = [VEBarValue valueWithTitles:@[@"",@"",@"",@"",@""] eventCallType:VEEventCallRatioType];
    }
    self.resulotionValue = [VEBarValue valueWithTitles:@[@"720P",@"1080P",@"540P"] eventCallType:VEEventCallResolutionType];
    self.camareValue = [VEBarValue valueWithImages:
                        @[
                            @"icon_topbar_camra".UI_VEToImage,
                        ]
                        eventCallType:VEEventCallCamraPosion
                        ];
    
    NSDictionary *userParm = [[NSUserDefaults standardUserDefaults] objectForKey:kUserParmForCamare];
    if (self.capManager.currentPreviewType != VECPCurrentPreViewTypeDuet) {
        
//        NSNumber *ratio = [userParm valueForKey:kUserParmForRatio];
//        if (ratio) {
//            self.ratioValue.curIndex = ratio.integerValue;
//        }
        self.ratioValue.curIndex = 0;

    }
    NSNumber *reslution = [userParm valueForKey:kUserParmForReslution];
    if (reslution) {
        self.resulotionValue.curIndex = reslution.integerValue;
    }
    NSNumber *time = [userParm valueForKey:kUserParmForTime];
    
    if (time) {
        self.timeValue.curIndex = time.integerValue;
    }
    NSArray *arr = nil;
    
    
    if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
        arr =
        @[
            self.timeValue,
            self.lightValue,
            self.resulotionValue,
            self.camareValue,
        ];
    } else {
        arr =
        @[
            self.timeValue,
            self.lightValue,
            self.ratioValue,
            self.resulotionValue,
            self.camareValue,
        ];
    }
    self.dataSourceArr = arr;
    [self.collecView reloadData];
    
    
    
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, VECPBaseBarSubViewTop, 55, VECPBaseBarSubViewH)];
        _closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_closeButton setImage:@"icon_close".UI_VEToImage forState:UIControlStateNormal];
        @weakify(self);
        [[_closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            UIViewController *vc = self.firstAvailableUIViewController;
            if (vc) {
                [self.capManager cancelVideoRecord];
                [vc dismissViewControllerAnimated:NO completion:^{
                                    
                }];
            }
        }];
    }
    
    return _closeButton;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(64.0, 50.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 0.0, 0.0,0.0);
   
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0.0;
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0.0;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}


#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    id obj = self.dataSourceArr[indexPath.section];
    
    VEBarValue *value = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        value = self.dataSourceArr[indexPath.section][indexPath.row];
    } else {
        value = self.dataSourceArr[indexPath.row];
    }
    
    if (self.capManager.boxState == VECPBoxStateInprocess) {
        switch (value.eventType) {
            case VEEventCallRatioType:
            case VEEventCallResolutionType:
                return;
                break;
                
            default:
                break;
        }
    }
    
    value.curIndex += 1;
    
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    [self.capManager dealWithValue:value];
}

- (void)setCapManager:(id<VECapProtocol>)capManager
{
    [super setCapManager:capManager];
    [self buildLayout];
    
    @weakify(self);
    [RACObserve(capManager, isDeviceChang) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!x) {
            return;
        }
        NSArray *arr = nil;
        if ([self.capManager GetCurrentCameraPosition] == AVCaptureDevicePositionBack) {
            arr =
            @[
                self.timeValue,
                self.lightValue,
                self.ratioValue,
                self.resulotionValue,
                self.camareValue,
            ];
            if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
                arr =
                @[
                    self.timeValue,
                    self.lightValue,
                    self.resulotionValue,
                    self.camareValue,
                ];
            }
        } else {
            arr =
            @[
                self.timeValue,
                self.lightValue,
                self.ratioValue,
                self.resulotionValue,
                self.camareValue,
            ];
            
            if (self.capManager.currentPreviewType == VECPCurrentPreViewTypeDuet) {
                arr =
                @[
                    self.timeValue,
                    self.lightValue,
                    self.resulotionValue,
                    self.camareValue,
                ];
            }
        }
        self.dataSourceArr = arr;
        [self.collecView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
    }];
}


@end
