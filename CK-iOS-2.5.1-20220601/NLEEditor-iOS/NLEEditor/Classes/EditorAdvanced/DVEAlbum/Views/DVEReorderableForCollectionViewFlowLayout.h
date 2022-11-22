//
//  DVEReorderableForCollectionViewFlowLayout.h
//  AWEStudio
//
//  Created by bytedance on 2018/5/18.
//  Copyright © 2018年 bytedance. All rights reserved.
//

//参照 https://github.com/lxcid/LXReorderableCollectionViewFlowLayout

#import <UIKit/UIKit.h>
@interface DVEPassTouchView: UIView
@property (strong, nonatomic) UITouch *passTouch;
@end

@interface DVEReorderableForCollectionViewFlowLayout : UICollectionViewFlowLayout <UIGestureRecognizerDelegate>

@property (assign, nonatomic) CGFloat scrollingSpeed;
@property (assign, nonatomic) UIEdgeInsets scrollingTriggerEdgeInsets;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) BOOL oneDirectionOnly; // reorderable in only scroll direction or in both horizontal/vertical directions
@property (assign, nonatomic) UIEdgeInsets draggableInset;
@property (assign, nonatomic) CGFloat highlightedScale;
@property (assign, nonatomic) BOOL hapticFeedbackEnabled;
@end

@protocol DVEReorderableForCollectionViewDataSource <UICollectionViewDataSource>

@optional

- (void)accReorderableCollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath;
- (void)accReorderableCollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;

- (BOOL)accReorderableCollectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)accReorderableCollectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol DVEReorderableForCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (void)accReorderableCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)accReorderableCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)accReorderableCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)accReorderableCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

@end
