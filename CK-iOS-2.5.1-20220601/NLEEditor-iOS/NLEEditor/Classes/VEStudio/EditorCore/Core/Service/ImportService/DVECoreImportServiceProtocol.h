//
//  DVECoreImportServiceProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import "DVECoreProtocol.h"
#import "DVEResourcePickerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreImportServiceProtocol <DVECoreProtocol>

// 点击 + 号
- (void)addResources:(NSArray<id<DVEResourcePickerModel>> *)resources
          completion:(dispatch_block_t)completion;

- (void)addNLEMainVideoWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                          completion:(dispatch_block_t _Nullable)completion;

// 画中画
- (void)addSubTrackResource:(id<DVEResourcePickerModel>)resource             
                 completion:(void(^)(NLETrackSlot_OC *slot))completion;

// 替换
- (void)replaceResourceForSlot:(NLETrackSlot_OC *)slot
                 albumResource:(id<DVEResourcePickerModel>)albumResource;

@end

NS_ASSUME_NONNULL_END
