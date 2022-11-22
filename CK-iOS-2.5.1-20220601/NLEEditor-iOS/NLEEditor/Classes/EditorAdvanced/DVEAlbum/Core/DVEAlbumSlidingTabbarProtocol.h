//
//  AWESlidingTabbarProtocol.h
//  AWEUIKit
//
//  Created by bytedance on 2018/6/22.
//

#import <Foundation/Foundation.h>
@class DVEAlbumSlidingViewController;

@protocol DVEAlbumSlidingTabbarProtocol <NSObject>

@property (nonatomic, weak) DVEAlbumSlidingViewController *slidingViewController;
@property (nonatomic, assign) NSInteger selectedIndex;

- (void)slidingControllerDidScroll:(UIScrollView *)scrollView;

@optional
- (void)updateSelectedLineFrame;
- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated tapped:(BOOL)tapped;

@end
