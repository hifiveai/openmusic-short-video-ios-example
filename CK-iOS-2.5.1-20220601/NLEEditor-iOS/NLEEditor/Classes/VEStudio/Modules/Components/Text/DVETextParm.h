//
//  DVETextParm.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DVEEffectValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETextParm : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) DVEEffectValue *font;
@property (nonatomic, strong) NSArray *textColor;
@property (nonatomic, strong) NSArray *outlineColor;
@property (nonatomic, assign) float outlineWidth;
@property (nonatomic, strong) NSArray *backgroundColor;
@property (nonatomic, strong) DVEEffectValue * alignment;
@property (nonatomic) int typeSettingKind;

@property (nonatomic, assign) float alpha;

/// 是否优先使用花字里的字体颜色，如果用户设置了花字，后设置字体颜色，这个需要置为NO
/// 如果用户点击花字，则这个需要设置为YES
@property (nonatomic, assign) BOOL useEffectDefaultColor;

@property (nonatomic, strong) NSArray *shadowColor;
@property (nonatomic, strong) NSArray *shadowOffset;
@property (nonatomic, assign) float shadowSmoothing;

@property (nonatomic, assign) float boldWidth;
@property (nonatomic, assign) float italicDegree;
@property (nonatomic, assign) BOOL underline;

@property (nonatomic, assign) float charSpacing;
@property (nonatomic, assign) float lineGap;

- (BOOL)isEqualToParm:(DVETextParm *)parm;

@end

NS_ASSUME_NONNULL_END
