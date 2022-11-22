//
//   DVEComponentAction+Private.h
//   NLEEditor
//
//   Created  by ByteDance on 2021/6/4.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction.h"
#import "DVEUIHelper.h"
#import "DVELoggerImpl.h"
#import "DVEComponentViewManager.h"
#import "DVEComponentViewManager+Private.h"
#import "DVEComponentAction+TrackView.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEBaseBar;

@interface DVEComponentAction (Private)

///剪辑上下文
@property (nonatomic, weak, readonly) DVEVCContext *vcContext;
///Bar依附VC
@property (nonatomic, weak, readonly) DVEViewController *parentVC;

-(void)showActionView:(DVEBaseBar*)barView;

-(void)dismissCurrentActionView;

@end

NS_ASSUME_NONNULL_END
