//
//  DVEAlbumPreviewAndSelectCell.m
//  AWEStudio-Pods-Aweme
//
//  Created by bytedance on 2020/3/15.
//

#import "DVEAlbumPreviewAndSelectCell.h"

@interface DVEAlbumPreviewAndSelectCell ()


@end

@implementation DVEAlbumPreviewAndSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)configCellWithAsset:(DVEAlbumAssetModel *)assetModel withPlayFrame:(CGRect)playFrame greyMode:(BOOL)greyMode{
    self.assetModel = assetModel;
}

- (void)removeCoverImageView{
}

- (void)setPlayerLayer:(AVPlayerLayer *)playerLayer withPlayerFrame:(CGRect)playerFrame{
}

@end
