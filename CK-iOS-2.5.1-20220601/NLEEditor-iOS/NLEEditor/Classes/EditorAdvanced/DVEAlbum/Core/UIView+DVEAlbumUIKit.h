//
//  UIView+ACCUIKit.h
//  ACCUIKit
//
//  Created by bytedance on 2019/9/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEAlbumViewDirection) {
    DVEAlbumViewDirectionLeft,
    DVEAlbumViewDirectionTop,
    DVEAlbumViewDirectionRight,
    DVEAlbumViewDirectionBottom
};

@interface UIView (DVEAlbumUIKit)

- (void)acc_addRotateAnimationWithDuration:(CGFloat)duration;
- (void)acc_addRotateAnimationWithDuration:(CGFloat)duration forKey:(nullable NSString *)key;

- (void)acc_addBlurEffect;
- (void)acc_addSystemBlurEffect:(UIBlurEffectStyle)style;

- (UIImage * _Nullable)acc_snapshotImage;
- (UIImage * _Nullable)acc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdate;
//-----由SMCheckProject工具删除-----
//- (UIImage *_Nullable)acc_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates withSize:(CGSize)size;

- (UIImageView * _Nullable)acc_snapshotImageView;

- (CGRect)acc_frameInView:(UIView * _Nonnull)view;

/**
 移出所有子控件
 */
- (void)acc_removeAllSubviews;


@end


@interface UIView (DVEAlbumLayout)

@property (nonatomic, assign) CGFloat acc_top;

@property (nonatomic, assign) CGFloat acc_bottom;

@property (nonatomic, assign) CGFloat acc_left;

@property (nonatomic, assign) CGFloat acc_right;

@property (nonatomic, assign) CGFloat acc_width;

@property (nonatomic, assign) CGFloat acc_height;

@property (nonatomic, assign) CGFloat acc_centerX;

@property (nonatomic, assign) CGFloat acc_centerY;

@property (nonatomic, assign) CGSize acc_size;

@property (nonatomic, assign) CGPoint acc_origin;

@end


@interface UIView (DVEAlbumHierarchy)

//-----由SMCheckProject工具删除-----
//- (id)acc_nearestAncestorOfClass:(Class)clazz;

@end


@interface UIView (DVEAlbumAddGestureRecognizer)

- (UITapGestureRecognizer *)acc_addSingleTapRecognizerWithTarget:(id)target action:(SEL)sel;

@end


@interface UIView (DVEAlbumViewImageMirror)

- (UIImage * _Nullable)acc_imageWithView;
- (UIImage * _Nullable)acc_imageWithViewOnScreenScale;
//-----由SMCheckProject工具删除-----
//- (UIImage * _Nullable)acc_imageWithViewOnScale:(CGFloat)scale;

@end


NS_ASSUME_NONNULL_END













