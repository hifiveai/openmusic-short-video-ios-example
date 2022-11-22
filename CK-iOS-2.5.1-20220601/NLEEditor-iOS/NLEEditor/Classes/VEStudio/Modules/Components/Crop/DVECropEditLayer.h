//
//  DVECropEditLayer.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/12.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVECropEditLayer : CAShapeLayer

- (instancetype)init;

- (void)hollowOutWithRect:(CGRect)rect duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
