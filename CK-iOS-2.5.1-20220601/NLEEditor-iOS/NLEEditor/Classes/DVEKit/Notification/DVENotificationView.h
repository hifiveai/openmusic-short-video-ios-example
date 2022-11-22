//
//  DVENotificationView.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DVEActionBlock)(UIView *view);

@interface DVENotificationView : UIView

@property (nonatomic, strong) UIView *contentView;

- (void)setupUI;

@end

@interface DVENotificationAction : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) DVEActionBlock actionBlock;

@end

NS_ASSUME_NONNULL_END
