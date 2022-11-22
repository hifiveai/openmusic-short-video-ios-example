//
//   VEResourceMusicModel.h
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/19.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <NLEEditor/DVEResourceMusicModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEResourceMusicModel : NSObject<DVEResourceMusicModelProtocol>

@property(nonatomic,assign)DVEResourceModelStatus modelState;

@end

NS_ASSUME_NONNULL_END
