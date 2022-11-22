//
//  DVEAlbumModuleConfigProtocol.h
//  CameraClient
//
//  Created by bytedance on 2020/4/27.
//

#import <Foundation/Foundation.h>

@protocol DVEAlbumModuleConfigProtocol <NSObject>

// EffectPlatform

- (NSString *)effectRequestDomainString;

- (BOOL)shouldEffectSetPoiParameters;

- (void)effectDealWithRegionDidChange;

- (void)configureExtraInfoForEffectPlatform;

// upload service

- (BOOL)shouldUploadServiceSetOptimizationPatameter;

// video router

//-----由SMCheckProject工具删除-----
//- (NSString *)routerTitleUserDisplayName:(id)user;

- (BOOL)needCheckLoginStatusWhenStartRecording;

// UIViewController+ACCUIKitEmptyPage

- (BOOL)shouldTitleColorUseDefaultConfigColor;

// FilterViewModel

- (BOOL)disableFilterEffectWhenUseNormalFilter;

// Cell Title

- (BOOL)useBoldTextForCellTitle;

// publish view model

- (BOOL)allowCommerceChallenge;

- (BOOL)useDefaultFormatNumberPolicy;

@end

//FOUNDATION_STATIC_INLINE id<DVEAlbumModuleConfigProtocol> TOCModuleConfig() {
//    return DVEAlbumUnionProvider(@protocol(DVEAlbumModuleConfigProtocol));
//}


