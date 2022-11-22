//
//  NSString+DVEAlbum.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/8/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (DVEAlbum)

- (UIColor *)dve_album_colorFromARGBHexString;

- (UIColor *)dve_album_colorFromRGBHexStringWithAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
