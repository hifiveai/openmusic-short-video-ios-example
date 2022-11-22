//
//   VEResourceLoader.h
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/14.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import <NLEEditor/DVEResourceLoaderProtocol.h>


NS_ASSUME_NONNULL_BEGIN

@interface VEResourceLoader : NSObject<DVEResourceLoaderProtocol>

- (void)duetValueArr:(void(^)(NSArray<DVEEffectValue*>* _Nullable datas,NSString* _Nullable error))handler;

@end

NS_ASSUME_NONNULL_END
