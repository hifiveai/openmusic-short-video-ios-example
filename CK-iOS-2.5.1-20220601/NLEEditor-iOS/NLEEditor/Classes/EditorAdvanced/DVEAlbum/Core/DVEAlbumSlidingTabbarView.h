//
//  DVEAlbumSlidingTabbarView.h
//  CameraClient
//
//  Created by bytedance on 2018/6/22.
//

#import <UIKit/UIKit.h>
#import "DVEAlbumSlidingTabbarProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DVEAlbumSlidingTabButtonStyle) {
    SCIFSlidingTabButtonStyleText = 0,
    SCIFSlidingTabButtonStyleIcon,
    SCIFSlidingTabButtonStyleIconAndText,
    SCIFSlidingTabButtonStyleOriginText, //传统样式.
    SCIFSlidingTabButtonStyleImageAndTitle,
    SCIFSlidingTabButtonStyleTextAndLineEqualLength,  //中间页tabview样式，文字与选中的线等长
};

@interface DVEAlbumSlidingTabButton : UIButton

- (void)showDot:(BOOL)show color:(nullable UIColor *)color;

@end

typedef void(^SCIFSlidingTabbarViewDidEndDeceleratingBlock)(NSInteger startIndex, NSInteger count);

@interface DVEAlbumSlidingTabbarView : UIView<DVEAlbumSlidingTabbarProtocol>

@property (nonatomic, assign) BOOL shouldShowTopLine;
@property (nonatomic, assign) BOOL shouldShowBottomLine;
@property (nonatomic, assign) BOOL shouldShowSelectionLine;
@property (nonatomic, assign) BOOL shouldShowButtonSeperationLine;
@property (nonatomic, strong) UIColor *selectionLineColor;
@property (nonatomic, strong) UIColor *topBottomLineColor;
@property (nonatomic, assign) BOOL shouldUpdateSelectButtonLine;

@property (nonatomic, assign) CGSize selectionLineSize;
@property (nonatomic, assign) CGFloat selectionLineCornerRadius;
@property (nonatomic, assign) BOOL enableSwitchAnimation; // default is NO
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, assign) BOOL needOptimizeTrackPointForVisibleRect;
//needOptimizeTrackPointForVisibleRect设置为YES时，如果在操作结束的时刻，屏幕内的可视区域未发生变化，则不执行didEndDeceleratingBlock
//2tab频道的tabbar在打点的时候，判断如果用户在操作（滑动/点击）结束后，屏幕中展示的tabbar区域未发生变化，则不重复打点；否则重新上报打点；

@property (nonatomic, copy) SCIFSlidingTabbarViewDidEndDeceleratingBlock didEndDeceleratingBlock;


- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(DVEAlbumSlidingTabButtonStyle)buttonStyle;

/**
初始化方法

@param frame tabview frame
@param buttonStyle 按钮样式(图片/文字)
@param dataArray 图片名/标题的数组
@param selectedDataArray 选中状态的图片名/标题的数组
@return 初始化后的对象
*/
- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(DVEAlbumSlidingTabButtonStyle)buttonStyle dataArray:(nullable NSArray<NSString *> *)dataArray selectedDataArray:(nullable NSArray<NSString *> *)selectedDataArray;

//-----由SMCheckProject工具删除-----
//- (void)configureText:(nullable NSString *)text image:(nullable UIImage *)image selectedText:(nullable NSString *)selectedText selectedImage:(nullable UIImage *)selectedImage index:(NSInteger)index;
- (void)resetDataArray:(nullable NSArray *)dataArray selectedDataArray:(nullable NSArray *)selectedDataArray;
//-----由SMCheckProject工具删除-----
//- (void)insertSeparatorArrowAndTitle:(nullable NSString *)titleString forImageStyleAtIndex:(NSInteger)index;//在指定index按钮的后面加一个箭头分割
//-----由SMCheckProject工具删除-----
//- (void)replaceButtonImage:(nullable UIImage *)image atIndex:(NSInteger)index;//给指定index按钮更新一个图
//-----由SMCheckProject工具删除-----
//- (void)replaceButtonImgae:(nullable UIImage *)image title:(nullable NSString *)titleString atIndex:(NSInteger)index;
//-----由SMCheckProject工具删除-----
//- (void)insertAtFrontWithButtonImage:(nullable UIImage *)image;//在第一位插入一个图的按钮
//-----由SMCheckProject工具删除-----
//- (void)insertAtFrontWithButtonImage:(nullable UIImage *)image title:(nullable NSString *)titleString;//在第一位插入一个图的按钮
- (void)configureButtonTextColor:(nullable UIColor *)color selectedTextColor:(nullable UIColor *)selectedColor;
//-----由SMCheckProject工具删除-----
//- (void)configureButtonTextFont:(nullable UIFont *)font hasShadow:(BOOL)hasShadow;
//-----由SMCheckProject工具删除-----
//- (void)configureButtonTextFont:(nullable UIFont *)font selectedFont:(nullable UIFont *)selectedFont;
//-----由SMCheckProject工具删除-----
//- (void)configureTitlePadding:(CGFloat)padding;
//-----由SMCheckProject工具删除-----
//- (void)configureTitleMinLength:(CGFloat)titleMinLength;
/**
 展示右上角的小圆点
 */
- (void)showButtonDot:(BOOL)show index:(NSInteger)index color:(nullable UIColor *)color;
//-----由SMCheckProject工具删除-----
//- (BOOL)isButtonDotShownOnIndex:(NSInteger)index;

//-----由SMCheckProject工具删除-----
//- (void)setTopLineColor:(nullable UIColor *)color;
//-----由SMCheckProject工具删除-----
//- (void)setBottomLineColor:(nullable UIColor *)color;
//-----由SMCheckProject工具删除-----
//- (void)setTopBottomLineColor:(nullable UIColor *)topBottomLineColor;

@end

NS_ASSUME_NONNULL_END














