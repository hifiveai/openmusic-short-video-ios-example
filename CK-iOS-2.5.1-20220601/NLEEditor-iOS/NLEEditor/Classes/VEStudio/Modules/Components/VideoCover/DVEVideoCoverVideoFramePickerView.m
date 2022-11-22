//
//  DVEVideoCoverVideoFramePickerView.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import "DVEVideoCoverVideoFramePickerView.h"
#import "DVEMacros.h"
#import <Masonry/Masonry.h>

static NSString * const DVEVideoCoverVideoFramePickerIdentifier = @"DVEVideoCoverVideoFramePickerIdentifier";

@interface DVEVideoCoverVideoFramePickerItem ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation DVEVideoCoverVideoFramePickerItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end

@interface DVEVideoCoverVideoFramePickerView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate
>

@property (nonatomic, strong) UIView *timeLine;
@property (nonatomic, strong) UICollectionView *videoFramesView;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, copy) NSArray<UIImage *> *frames;

@end

@implementation DVEVideoCoverVideoFramePickerView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    
    [self addSubview:self.videoFramesView];
    [self addSubview:self.timeLine];
    [self addSubview:self.hintLabel];
    
    [self.timeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(2, 59));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top);
    }];
    
    [self.videoFramesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top).offset(4);
    }];
    
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 24));
        make.top.mas_equalTo(self.timeLine.mas_bottom).offset(18);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
}

- (void)updateCurrentTimeRatio:(CGFloat)ratio {
    CGFloat scrollDistance = self.videoFramesView.bounds.size.height * self.frames.count * ratio;
    [self.videoFramesView setContentOffset:CGPointMake(scrollDistance, 0)];
}

- (void)updateVideoFrames:(NSArray<UIImage *> *)frames {
    self.frames = frames;
    [self.videoFramesView reloadData];
    [self.videoFramesView layoutIfNeeded];
}

- (UIView *)timeLine {
    if (!_timeLine) {
        _timeLine = [[UIView alloc] init];
        _timeLine.backgroundColor = [UIColor whiteColor];
        _timeLine.layer.cornerRadius = 1;
        _timeLine.layer.masksToBounds = YES;
    }
    return _timeLine;
}

- (UICollectionView *)videoFramesView {
    if (!_videoFramesView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _videoFramesView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                              collectionViewLayout:layout];
        _videoFramesView.backgroundColor = [UIColor clearColor];
        _videoFramesView.showsVerticalScrollIndicator = NO;
        _videoFramesView.showsHorizontalScrollIndicator = NO;
        _videoFramesView.allowsMultipleSelection = NO;
        _videoFramesView.delegate = self;
        _videoFramesView.dataSource = self;
        [_videoFramesView registerClass:[DVEVideoCoverVideoFramePickerItem class]
             forCellWithReuseIdentifier:DVEVideoCoverVideoFramePickerIdentifier];
        
    }
    return _videoFramesView;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = NLELocalizedString(@"ck_seek_choose_cover", @"滑动选择封面");
        _hintLabel.textColor = [UIColor whiteColor];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.font = SCRegularFont(14);
        _hintLabel.alpha = 0.5;
    }
    return _hintLabel;
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.frames count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DVEVideoCoverVideoFramePickerItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DVEVideoCoverVideoFramePickerIdentifier forIndexPath:indexPath];
    UIImage *image = self.frames[indexPath.row];
    cell.imageView.image = image;
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    CGFloat leftInset = [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat rightInset = leftInset;
    return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.height,collectionView.bounds.size.height);
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollDistance = scrollView.contentOffset.x;
    CGFloat ratio = scrollDistance / (self.videoFramesView.bounds.size.height * self.frames.count);
    ratio = fmax(ratio, 0.0);
    ratio = fmin(ratio, 1.0);
    [self.delegate updatePreviewWithCurrentTimeRatio:ratio];
}


@end
