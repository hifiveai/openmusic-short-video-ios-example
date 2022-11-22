//
//  TOCMacros.h
//  Pods
//
//  Created by bytedance on 2020/11/26.
//

#ifndef TOCMacros_h
#define TOCMacros_h

#define TOCSYSTEM_VERSION_LESS_THAN(v)                        ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define TOCSTRINGIZE(x) #x
#define TOCSTRINGIZE2(x) TOCSTRINGIZE(x)
#define TOCFOOLITERAL(x) @ TOCSTRINGIZE2(x)

//async
#ifndef toc_dispatch_queue_async_safe
#define toc_dispatch_queue_async_safe(queue, block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue)) {\
block();\
} else {\
dispatch_async(queue, block);\
}
#endif

#ifndef toc_dispatch_main_async_safe
#define toc_dispatch_main_async_safe(block) toc_dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

//screen
#define TOC_SCREEN_WIDTH    ([UIApplication sharedApplication].keyWindow.bounds.size.width)
#define TOC_SCREEN_HEIGHT   ([UIApplication sharedApplication].keyWindow.bounds.size.height)
#define TOC_SCREEN_SCALE    [[UIScreen mainScreen] scale]
#define TOC_ROOT_VC_HEIGHT  ([UIApplication sharedApplication].delegate.window.rootViewController.view.frame.size.height)

//size
#define TOC_STATUS_BAR_HEIGHT          [UIApplication sharedApplication].statusBarFrame.size.height
#define TOC_NAVIGATION_BAR_OFFSET      ([UIDevice acc_isIPhoneX] ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4 : 24) : 0)
#define TOC_IPHONE_X_BOTTOM_OFFSET     ([UIDevice acc_isIPhoneX] ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20 : 34) : 0)
#define TOC_STATUS_BAR_NORMAL_HEIGHT   (20 + TOC_NAVIGATION_BAR_OFFSET)
#define TOC_NAVIGATION_BAR_HEIGHT      (64 + TOC_NAVIGATION_BAR_OFFSET)

//color
#define TOCColorFromRGB(r, g, b)        TOCColorFromRGBA((r), (g), (b), 1)
#define TOCColorFromRGBA(r, g, b, a)    [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define TOCUIColorFromRGBA(__rgb__, __alpha__) \
[UIColor colorWithRed:((float)(((__rgb__) & 0xFF0000) >> 16))/255.0 \
                green:((float)(((__rgb__) & 0xFF00) >> 8))/255.0 \
                blue:((float)((__rgb__) & 0xFF))/255.0 \
                alpha:(__alpha__)]
#define TOCColorFromHexString(hexString) [UIColor acc_colorWithHex:hexString]

//float
#define TOC_FLOAT_ZERO                      0.00001f
#define TOC_FLOAT_EQUAL_ZERO(a)             (fabs(a) <= TOC_FLOAT_ZERO)
#define TOC_FLOAT_GREATER_THAN(a, b)        ((a) - (b) >= TOC_FLOAT_ZERO)
#define TOC_FLOAT_EQUAL_TO(a, b)            TOC_FLOAT_EQUAL_ZERO((a) - (b))
#define TOC_FLOAT_LESS_THAN(a, b)           ((a) - (b) <= -TOC_FLOAT_ZERO)

//block
#define TOCBLOCK_INVOKE(block, ...)   (block ? block(__VA_ARGS__) : 0)

//empty
#ifndef TOC_isEmptyString
#define TOC_isEmptyString(param)      ( !(param) ? YES : ([(param) isKindOfClass:[NSString class]] ? (param).length == 0 : NO) )
#endif

#ifndef TOC_isEmptyArray
#define TOC_isEmptyArray(param)       ( !(param) ? YES : ([(param) isKindOfClass:[NSArray class]] ? (param).count == 0 : NO) )
#endif

#ifndef TOC_isEmptyDictionary
#define TOC_isEmptyDictionary(param)    ( !(param) ? YES : ([(param) isKindOfClass:[NSDictionary class]] ? (param).count == 0 : NO) )
#endif

//weakfy
#ifndef btd_keywordify
#if DEBUG
#define btd_keywordify autoreleasepool {}
#else
#define btd_keywordify try {} @catch (...) {}
#endif
#endif

#ifndef weakify
#if __has_feature(objc_arc)
#define weakify(object) btd_keywordify __weak __unused __typeof__(object) weak##_##object = object;
#else
#define weakify(object) btd_keywordify __block __unused __typeof__(object) block##_##object = object;
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify(object) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    btd_keywordify __unused __typeof__(object) object = weak##_##object; \
    _Pragma("clang diagnostic pop")
#else
#define strongify(object) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    btd_keywordify __unused __typeof__(object) object = block##_##object; \
    _Pragma("clang diagnostic pop")
#endif
#endif


// log
#define DVEAlbum_LogDebugTag(Tag, format, arg...) __DVEAlbumLog(Tag, DVEAlbumLogLevelDebug, format, ##arg);
#define DVEAlbum_LogInfoTag(Tag, format, arg...) __DVEAlbumLog(Tag, DVEAlbumLogLevelInfo, format, ##arg);
#define DVEAlbum_LogWarningTag(Tag, format, arg...) __DVEAlbumLog(Tag, DVEAlbumLogLevelWarning, format, ##arg);
#define DVEAlbum_LogErrorTag(Tag, format, arg...) __DVEAlbumLog(Tag, DVEAlbumLogLevelError, format, ##arg);

#define __DVEAlbumLog(Tag, Level, format, arg...) [DVEAlbumCutSameSDK.shareInstance.logger log:Tag level:Level file:__FILE__ function:__FUNCTION__ line:__LINE__ message:format, ##arg];

#endif /* TOCMacros_h */
