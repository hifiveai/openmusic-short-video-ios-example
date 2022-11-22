//
//  CKEditorHeader.h
//  Pods
//
//  Created by bytedance on 2021/7/6.
//

#ifndef CKEditorHeader_h
#define CKEditorHeader_h

#define VE_is_iphone 1

#import <UIKit/UIKit.h>
#import "UIView+VEExt.h"
#import "NSObject+VEAdd.h"
#import <NLEEditor/DVEToast.h>
// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>
#import "NSString+UIVEToImage.h"
#import "NSString+VEIEPath.h"
#import "UIView+VEFindVC.h"
#import "UIView+VERACSupport.h"
#import "UIView+VEExt.h"
#import "NSObject+VEAdd.h"
#import "VEVButton.h"
#import "VEHButton.h"
#import "VEBarValue.h"
#import "DVEEffectValue.h"
#import "UIButton+layout.h"
#import "VEUIHelper.h"
#import <NLEEditor/DVEEffectValue.h>
#import <NLEPlatform/NLEInterface.h>
#import <DVETrackKit/DVEMediaContext.h>



// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

#define CKEditorOptionsStringValue(__value__, __placeholder__) (__value__ ? __value__ : __placeholder__)
#define CKEditorNSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil]
#define CKEditorLocStringWithKey(key, placeholder) ([CKEditorNSLocalizedString(CKEditorOptionsStringValue(key,@""),@"") isEqualToString:CKEditorOptionsStringValue(key,@"")] ? CKEditorOptionsStringValue(placeholder,@"") : (CKEditorNSLocalizedString(CKEditorOptionsStringValue(key,@""),@"")))

#ifndef __OPTIMIZE__
#define NSLog(s, ... ) NSLog( @"<%@(%d)> %@",[[NSString stringWithUTF8String:__FUNCTION__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog(...) {}
#endif

#if DEBUG
    #define ADLog(fmt,...) NSLog((@"[arderbud] " fmt), ##__VA_ARGS__)
#else
    #define ADLog(...)
#endif
#define VE_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#define VE_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define vemargn 4
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define colorWithHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:(a)]
#define HEXRGBCOLOR(h) RGBCOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF))
#define HEXRGBACOLOR(h,a) RGBACOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF), a)

#define Font(x)                         [UIFont systemFontOfSize : x]
#define SCRegularFont(x)                [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define HelBoldFont(x)                  [UIFont fontWithName:@"HelveticaNeue-Bold" size:x]
#define ItalicFont(x)                   [UIFont italicSystemFontOfSize:x]
#define BoldFont(x)                     [UIFont boldSystemFontOfSize : x]

//weak&strong
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif



#endif /* CKEditorHeader_h */
