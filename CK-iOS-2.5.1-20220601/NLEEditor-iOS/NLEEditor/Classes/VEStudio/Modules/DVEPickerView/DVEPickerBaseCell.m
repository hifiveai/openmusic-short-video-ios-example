//
//  DVEPickerBaseCell.m
//  CameraClient
//
//  Created by bytedance on 2020/7/26.
//

#import "DVEPickerBaseCell.h"
#import "DVEPickerViewModels.h"
#import "DVELoadingView.h"

@interface DVEPickerBaseCell()

@property (nonatomic, assign, readwrite) BOOL stickerSelected;
@property (nonatomic, strong) UIView *downloadView;
@property (nonatomic, strong) UIView *downloadingView;
@property (nonatomic, strong) UIView *downloadFailView;
@end

@implementation DVEPickerBaseCell

-(instancetype)init {
    if(self = [super init]){

    }
    return self;
}



- (void)setStickerSelected:(BOOL)stickerSelected animated:(BOOL)animated
{
    _stickerSelected = stickerSelected;
}

- (void)updateStickerIconImage
{

}

- (void)updateShowStatus{
    CGFloat w = CGRectGetWidth(self.frame);
    if(self.model.status == DVEResourceModelStatusNeedDownlod){
        [self addSubview:self.downloadView];
    }else{
        [self.downloadView removeFromSuperview];
        self.downloadView = nil;
    }
    
    if(self.model.status == DVEResourceModelStatusDownloding){
        [self addSubview:self.downloadingView];
    }else{
        [self.downloadingView removeFromSuperview];
        self.downloadingView = nil;
    }
    
    if(self.model.status == DVEResourceModelStatusDownlodFailed){
        [self addSubview:self.downloadFailView];
    }else{
        [self.downloadFailView removeFromSuperview];
        self.downloadFailView = nil;
    }
}


- (UIView *)downloadView {
    if(!_downloadView) {
        _downloadView = [[UIImageView alloc] initWithImage:@"icon_effects_download".dve_toImage];
        CGFloat w = CGRectGetWidth(self.frame);
        _downloadView.frame = CGRectMake(w - 9, 0, 9, 9);
    }
    return _downloadView;
}

- (UIView *)downloadingView {
    if(!_downloadingView) {
        DVELoadingType* type = [DVELoadingType smallLoadingType];
        DVELoadingView* view = [[DVELoadingView alloc] initWithFrame:self.bounds];
        [view setLottieLoadingWithType:type];
        _downloadingView = view;
    }
    return _downloadingView;
}

- (UIView *)downloadFailView {
    if(!_downloadFailView) {
        _downloadFailView = [[UIImageView alloc] initWithImage:@"icon_effects_download".dve_toImage];
        CGFloat w = CGRectGetWidth(self.frame);
        _downloadFailView.frame = CGRectMake(w - 9, 0, 9, 9);
    }
    return _downloadFailView;
}

@end
