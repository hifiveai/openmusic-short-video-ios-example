//
//  UIDevice+ACCHardware.h
//  Pods
//
//  Created by bytedance on 2019/8/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,SCIFScreenWidthCategory)  {
    SCIFScreenWidthCategoryiPhone5,
    SCIFScreenWidthCategoryiPhone6,
    SCIFScreenWidthCategoryiPhone6Plus,

    SCIFScreenWidthCategoryiPad9_7,
    SCIFScreenWidthCategoryiPad10_5,
    SCIFScreenWidthCategoryiPad12_9,
};

typedef NS_ENUM(NSUInteger,SCIFScreenHeightCategory) {
    SCIFScreenHeightCategoryiPhone4s,
    SCIFScreenHeightCategoryiPhone5,
    SCIFScreenHeightCategoryiPhone6,
    SCIFScreenHeightCategoryiPhone6Plus,
    SCIFScreenHeightCategoryiPhoneX,
    SCIFScreenHeightCategoryiPhoneXSMax,

    SCIFScreenHeightCategoryiPad9_7,
    SCIFScreenHeightCategoryiPad10_5,
    SCIFScreenHeightCategoryiPad12_9,
};

typedef NS_ENUM(NSUInteger,SCIFScreenRatoCategory) {
    SCIFScreenRatoCategoryiPhoneX,
    SCIFScreenRatoCategoryiPhone16_9,
    SCIFScreenRatoCategoryiPhone4_3,
};

@interface UIDevice (DVEAlbumHardware)

//是否是低于6s的手机
+ (BOOL)acc_isPoorThanIPhone6S;
+ (BOOL)acc_isPoorThanIPhone6;
+ (BOOL)acc_isPoorThanIPhone5s;
+ (BOOL)acc_isPoorThanIPhone5;

+ (BOOL)acc_isBetterThanIPhone7;
+ (BOOL)acc_isIPhone7Plus;
+ (BOOL)acc_isIPhone;
+ (BOOL)acc_isIPad;

+ (SCIFScreenWidthCategory)acc_screenWidthCategory;
+ (SCIFScreenHeightCategory)acc_screenHeightCategory;
+ (SCIFScreenRatoCategory)acc_screenRatoCategory;

// 不到万不得已不要使用这个方法，使用 Safe Layout Guide 进行适配
+ (BOOL)acc_isIPhoneX;
+ (BOOL)acc_isIPhoneXsMax;

@end

NS_ASSUME_NONNULL_END
