//
//  DVEAlbumResourceUnion.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/26.
//

#import "DVEAlbumResourceUnion.h"
#import "DVEAlbumMacros.h"
#import "DVEAlbumResourceBundleProtocol.h"
#import "NSString+DVEAlbum.h"

@interface DVEAlbumResourceUnion ()

+ (NSDictionary<NSString *, NSString *> *)colorDict;

@end

@implementation DVEAlbumResourceUnion

static NSDictionary<NSString *, NSString *> *_colorDict = nil;

+ (NSDictionary<NSString *,NSString *> *)colorDict {
    if (!_colorDict) {
        _colorDict = [DVEAlbumResourceUnion p_colorDictionary];
    }
    return _colorDict;
}


+ (NSDictionary *)p_colorDictionary {
    NSArray<NSString *> *colorNames = @[@"color_biz", @"color_template"];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *colorName in colorNames) {
        NSString *path = [[self album_mainBundle] pathForResource:colorName ofType:@"strings"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [result addEntriesFromDictionary:dict];
    }
    return [result copy];
}

+ (NSBundle *)album_mainBundle
{
    return [self bundleWithName:@"DVEAlbum"];
}

+ (NSBundle *)bundleWithName:(NSString *)name
{
    NSString *bundleName = [NSString stringWithFormat:@"%@.bundle", name];
    NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:bundleName];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

@end

@implementation DVEAlbumResourceUnion (Color)

+ (UIColor *)toc_colorWithName:(NSString *)colorName
{
    if (TOC_isEmptyString(colorName)) {
        return nil;
    }

    NSString *colorValue = [DVEAlbumResourceUnion colorDict][colorName];
    NSAssert(colorValue, @"colorValue should not be nil!!!");
    
    NSArray *colorArr = [colorValue componentsSeparatedByString:@"/"];
    if (colorArr.count == 2) {
        NSString *colorExcludeAlpha = colorArr.firstObject;
        CGFloat alpha = [colorArr.lastObject doubleValue];
        return [colorExcludeAlpha dve_album_colorFromRGBHexStringWithAlpha:alpha];
    } else {
        return [colorName dve_album_colorFromARGBHexString];
    }
}

//+ (NSString *)toc_darkNameWithColorName:(NSString *)colorName
//{
//    NSString *templateString = DVEAlbumResourceUnion.cameraResourceBundle.toc_colorTemplate(colorName);
//    colorName = TOC_isEmptyString(templateString) ? colorName : templateString;
//    return [NSString stringWithFormat:@"%@_dark", colorName];
//}
//
//+ (NSString *)toc_lightNameWithColorName:(NSString *)colorName
//{
//    NSString *templateString = DVEAlbumResourceUnion.cameraResourceBundle.toc_colorTemplate(colorName);
//    colorName = TOC_isEmptyString(templateString) ? colorName : templateString;
//    return [NSString stringWithFormat:@"%@_light", colorName];
//}

@end

@implementation DVEAlbumResourceUnion (Image)

+ (UIImage *)toc_imageWithName:(NSString *)name
{
    if (TOC_isEmptyString(name)) {
        return nil;
    }

    UIImage *image = [UIImage imageNamed:name
                                inBundle:[DVEAlbumResourceUnion album_mainBundle]
           compatibleWithTraitCollection:nil];
    return image;
}

@end


