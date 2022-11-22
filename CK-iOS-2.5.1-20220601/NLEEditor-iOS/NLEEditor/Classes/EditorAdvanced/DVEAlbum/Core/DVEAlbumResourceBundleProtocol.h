//
//  DVEAlbumResourceBundleProtocol.h
//  VideoTemplate
//
//  Created by bytedance on 2020/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEAlbumResourceBundleProtocol <NSObject>

- (NSString *)currentResourceBundleName;

- (BOOL)isDarkMode;
// support iOS13 dark mode
- (BOOL)supportDarkMode;

@optional
- (BOOL)isLightMode;

@end

NS_ASSUME_NONNULL_END
