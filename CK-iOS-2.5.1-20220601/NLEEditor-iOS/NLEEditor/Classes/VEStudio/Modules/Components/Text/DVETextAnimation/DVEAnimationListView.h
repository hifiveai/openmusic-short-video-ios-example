//
//  DVEAnimationListView.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/1.
//

#import <UIKit/UIKit.h>
#import "DVETextAnimationModel.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEAnimationListView;

@protocol DVEAnimationListViewDelegate <NSObject>

- (void)listView:(DVEAnimationListView *)listView didSelectAnimation:(DVETextAnimationModel *)animation;

@end

@interface DVEAnimationListView : UIView

@property (nonatomic, weak) id<DVEAnimationListViewDelegate> delegate;


- (void)showAnimations:(NSArray<DVETextAnimationModel *> *)animations selectedAnimation:(DVETextAnimationModel *)animation;

@end

NS_ASSUME_NONNULL_END
