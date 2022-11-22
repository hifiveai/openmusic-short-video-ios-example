//
//  DVEMaskConfigModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/13.
//

#import <Foundation/Foundation.h>
#import "DVEMaskEditAdpter.h"
#import "DVEEffectValue.h"


NS_ASSUME_NONNULL_BEGIN

@interface DVEMaskConfigModel : NSObject

//蒙版类型
@property (nonatomic, assign) VEMaskEditType type;
//当前的文件素材模型，主要使用本地路径sourcePath
@property (nonatomic, strong) DVEEffectValue *curValue;
//蒙版图形长（归一化值）
@property (nonatomic, assign) CGFloat width;
//蒙版图形高（归一化值）
@property (nonatomic, assign) CGFloat height;
//蒙版旋转角度
@property (nonatomic, assign) CGFloat rotation;
//蒙版几何图形（SVG）原始比例
@property (nonatomic, assign) CGFloat aspectRatio;
//蒙版圆角（归一化值）
@property (nonatomic, assign) CGFloat roundCorner;
//蒙版羽化值（归一化值）
@property (nonatomic, assign) CGFloat feather;
//蒙版中心（归一化值）
@property (nonatomic, assign) CGPoint center;
//蒙版SVG图形路径
@property (nonatomic, copy) NSString *svgFilePath;
//蒙版所在视频的borderSize
@property (nonatomic, assign) CGSize borderSize;
//是否反转
@property (nonatomic, assign) BOOL invert;

- (instancetype)initWithBorderSize:(CGSize)borderSize;

@end

NS_ASSUME_NONNULL_END
