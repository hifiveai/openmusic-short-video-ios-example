//
//  NSObject+DVEAlbumSwizzle.h
//  CutSameIF
//
//  Created by bytedance on 2021/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DVEAlbumSwizzle)

+ (void)DVEAlbum_swizzleMethodsOfClass:(Class)cls originSelector:(SEL)originSelector targetSelector:(SEL)targetSelector;

@end

NS_ASSUME_NONNULL_END
