//
//  DVEEffectValue.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVEResourceCategoryModelProtocol.h"
#import "NSString+VEIEPath.h"
#import "NSString+VEToImage.h"

typedef NS_OPTIONS(NSUInteger, VEEffectValueType) {

    VEEffectValueTypeNone          = 0 << 0,
    VEEffectValueTypeFilter         = 1 << 0,
    VEEffectValueTypeSticker          = 1 << 1,
    VEEffectValueTypeBeauty  = 1 << 2,
    VEEffectValueTypeCanvasStyleNone,
    VEEffectValueTypeCanvasStyleLocal,
    VEEffectValueTypeCanvasStyleNetwork,
};

typedef NS_ENUM(NSUInteger, VEEffectValueState) {

    VEEffectValueStateNone          = 0,
    VEEffectValueStateInUse        ,
    VEEffectValueStateShuntDown          ,
    

};

typedef NS_ENUM(NSUInteger, VEEffectBeautyType) {

    VEEffectBeautyTypeFace        = 0,
    VEEffectBeautyTypeVFace          ,
    VEEffectBeautyTypeBody          ,
    VEEffectBeautyTypeMakeup
    

};

typedef NS_ENUM(NSUInteger, VEEffectBeautyTypeMakeupSubType) {

    VEEffectBeautyTypeMakeupSubTypeBlush = 0,
    VEEffectBeautyTypeMakeupSubTypeLip,
    VEEffectBeautyTypeMakeupSubTypeFacial,
    VEEffectBeautyTypeMakeupSubTypePupil,
    VEEffectBeautyTypeMakeupSubTypeHair,
    VEEffectBeautyTypeMakeupSubTypeEyeShadow,
    VEEffectBeautyTypeMakeupSubTypeEyebrow,    

};

NS_ASSUME_NONNULL_BEGIN

@interface DVEEffectValue : NSObject<NSCopying,NSMutableCopying,DVEResourceModelProtocol>
@property (nonatomic, assign) VEEffectValueType valueType;
@property (nonatomic, assign) VEEffectBeautyType beautyType;
@property (nonatomic, assign) VEEffectBeautyTypeMakeupSubType makeSubUp;
@property (nonatomic, assign) VEEffectValueState valueState;
@property (nonatomic, assign) NSInteger subSelectIndex;
@property (nonatomic, strong) NSString *composerTag;
@property (nonatomic, strong) NSString *composerPath;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) float indesty;
@property (nonatomic, strong) NSNumber *animationType;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) id<DVEResourceModelProtocol> injectModel;

- (instancetype)initWithType:(VEEffectValueType)type
                      Bundle:(NSString *)bundle
                        name:(NSString *)name
                       imageURL:(NSURL *)imageURL
                       assetImage:(UIImage *)assetImage
                         key:(NSString *)key
                     indesty:(float)indesty;

- (instancetype)initWithType:(VEEffectValueType)type
                      Bundle:(NSString *)bundle
                        name:(NSString *)name
                       image:(NSString *)image
                         key:(NSString *)key
                     indesty:(float)indesty;

- (instancetype)initWithInjectModel:(id<DVEResourceModelProtocol>)model;

@end

NS_ASSUME_NONNULL_END
