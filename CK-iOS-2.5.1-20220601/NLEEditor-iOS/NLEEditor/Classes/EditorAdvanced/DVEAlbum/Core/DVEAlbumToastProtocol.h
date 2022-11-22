//
//  DVEAlbumToastProtocol.h
//  VideoTemplate
//
//  Created by bytedance on 2020/11/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEAlbumToastProtocol <NSObject>

@optional

- (void)show:(NSString *)message;

- (void)showSuccess:(NSString *)message;

- (void)showError:(NSString *)message;

- (void)show:(NSString *)message onView:(UIView *)view;

- (void)showError:(NSString *)message onView:(UIView *)view;

- (void)showSuccess:(NSString *)message onView:(UIView *)view;

- (void)showToast:(NSString *)message;

- (void)dismissToast;

@end

FOUNDATION_STATIC_INLINE id<DVEAlbumToastProtocol> TOCToast() {
    return nil;
}

NS_ASSUME_NONNULL_END
