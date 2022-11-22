//
//  DVECropGridView.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import <UIKit/UIKit.h>
#import "DVECropDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECropGridVertexView : UIView

@property (nonatomic, assign) DVECropGridVertexViewType type;

- (instancetype)initWithFrame:(CGRect)frame
                         type:(DVECropGridVertexViewType)type;

- (void)addBorderWithType:(DVECropGridVertexViewType)type;

@end

@interface DVECropGridView : UIView

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
