//
//  DVEAlbumResourceUnion.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "DVEAlbumColorNameDefines.h"

#define TOCResourceColor(name) [DVEAlbumResourceUnion toc_colorWithName:name]
#define TOCResourceImage(name) [DVEAlbumResourceUnion toc_imageWithName:name]

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumResourceUnion : NSObject


@end


@interface DVEAlbumResourceUnion (Color)

+ (UIColor *)toc_colorWithName:(NSString *)colorName;

@end

@interface DVEAlbumResourceUnion (Image)

+ (UIImage *)toc_imageWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
