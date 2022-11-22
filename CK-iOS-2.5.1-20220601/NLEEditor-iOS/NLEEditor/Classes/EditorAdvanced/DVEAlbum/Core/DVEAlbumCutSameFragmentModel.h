//
//  DVEAlbumCutSameFragmentModel.h
//  VideoTemplate
//
//  Created by bytedance on 2021/4/20.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumBaseModel.h"

NS_ASSUME_NONNULL_BEGIN
/// 片段模型
@interface DVEAlbumCutSameFragmentModel : DVEAlbumBaseModel

@property (nonatomic, copy) NSNumber *videoWidth;
@property (nonatomic, copy) NSNumber *videoHeight;
@property (nonatomic, copy) NSNumber *duration;
@property (nonatomic, copy) NSString *materialId;

@property (nonatomic, assign) BOOL needReverse;

@end

NS_ASSUME_NONNULL_END
