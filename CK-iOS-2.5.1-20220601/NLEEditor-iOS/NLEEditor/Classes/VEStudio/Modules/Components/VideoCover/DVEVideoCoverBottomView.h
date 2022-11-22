//
//  DVEVideoCoverBottomView.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEVideoCoverBottomViewDelegate <NSObject>

- (void)showTextView;

@end

@interface DVEVideoCoverBottomView : UIView

@property (nonatomic, weak) id<DVEVideoCoverBottomViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
