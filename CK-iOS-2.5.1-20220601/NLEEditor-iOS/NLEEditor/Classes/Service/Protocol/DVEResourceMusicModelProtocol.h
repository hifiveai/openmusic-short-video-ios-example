//
//   DVEResourceMusicModelProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/19.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEResourceModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@protocol DVEResourceMusicModelProtocol <DVEResourceModelProtocol>

@property (nonatomic, copy) NSString *singer;


/// 展示点击View
/// @param currentView 已有的View
-(UIView*)actionView:(UIView*)currentView;

/// 执行加载
/// @param userInfo 用户数据，在handler回传
/// @param handler 加载后回调
/// return false:不做actionView刷新操作 true:触发actionView
-(BOOL)loadWithUserInfo:(id)userInfo Handler:(void(^)(id userInfo))handler;

@end

NS_ASSUME_NONNULL_END
