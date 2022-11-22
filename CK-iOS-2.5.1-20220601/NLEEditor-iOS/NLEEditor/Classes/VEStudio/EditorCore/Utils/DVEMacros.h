//
//  DVEMacros.h
//  Pods
//
//  Created by bytedance on 2021/3/31.
//

#ifndef DVEMacros_h
#define DVEMacros_h


#define NLEEditorOptionsStringValue(__value__, __placeholder__) __value__
#define NLEEditorNSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil]
#define NLELocalizedString(key, placeholder) ([NLEEditorNSLocalizedString(NLEEditorOptionsStringValue(key,@""),@"") isEqualToString:NLEEditorOptionsStringValue(key,@"")] ? NLEEditorOptionsStringValue(placeholder,@"") : (NLEEditorNSLocalizedString(NLEEditorOptionsStringValue(key,@""),@"")))

#define VEOptionsStringValue(__value__, __placeholder__) (__value__.length > 0 ? __value__ : __placeholder__)

#define VE_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

#define VE_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#define colorWithHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define colorWithHexAlpha(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:alphaValue]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:(a)]
#define HEXRGBCOLOR(h) RGBCOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF))
#define HEXRGBACOLOR(h,a) RGBACOLOR(((h>>16)&0xFF), ((h>>8)&0xFF), (h&0xFF), a)

#define Font(x)                         [UIFont systemFontOfSize : x]
#define SCRegularFont(x)                [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define SCSemiboldFont(x)                [UIFont fontWithName:@"PingFangSC-Semibold" size:x]
#define HelBoldFont(x)                  [UIFont fontWithName:@"HelveticaNeue-Bold" size:x]
#define ItalicFont(x)                   [UIFont italicSystemFontOfSize:x]
#define BoldFont(x)                     [UIFont boldSystemFontOfSize : x]

#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)

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

// float
#define DVE_FLOAT_ZERO                      0.00001f
#define DVE_FLOAT_EQUAL_ZERO(a)             (fabs(a) <= DVE_FLOAT_ZERO)
#define DVE_FLOAT_GREATER_THAN(a, b)        ((a) - (b) >= DVE_FLOAT_ZERO)
#define DVE_FLOAT_EQUAL_TO(a, b)            DVE_FLOAT_EQUAL_ZERO((a) - (b))
#define DVE_FLOAT_LESS_THAN(a, b)           ((a) - (b) <= -DVE_FLOAT_ZERO)

#endif /* DVEMacros_h */
