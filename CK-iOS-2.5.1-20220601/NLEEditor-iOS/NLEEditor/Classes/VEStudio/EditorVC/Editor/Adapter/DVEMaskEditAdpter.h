//
//  DVEMaskEditAdpter.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/8.
//

#import <Foundation/Foundation.h>
#import "DVEVCContext.h"

@class DVEVCContext;
typedef NS_ENUM(NSInteger, VEMaskEditType) {
    VEMaskEditTypeNone = 0,
    VEMaskEditTypeLine,
    VEMaskEditTypeMirror,
    VEMaskEditTypeRoundShape,
    VEMaskEditTypeRectangle,
    VEMaskEditTypeHeartShape,
    VEMaskEditTypeStarShape
   
};

NS_ASSUME_NONNULL_BEGIN
@class DVEMaskConfigModel;
@class DVEMaskBar;

@interface DVEMaskEditAdpter : NSObject

@property (nonatomic,weak) DVEVCContext *vcContext;
@property (nonatomic, assign) VEMaskEditType curType;
/// 禁止关键帧回调刷新
/// 在滑动编辑框或者滑杆的时候，都会触发commit事件，从而会触发vc关键帧监听回调
/// 这样会导致重复刷新UI，所以在这个过程中需要disableKeyframeUpdate忽略关键帧回调，松手后再打开回调
@property (nonatomic, assign) BOOL disableKeyframeUpdate;

- (void)showInPreview:(UIView *)view withConfigModel:(DVEMaskConfigModel *)model;
- (void)setupMaskBar:(DVEMaskBar*)bar;
- (void)hideFromPreview;
- (void)reloadConfigModel;
@end

NS_ASSUME_NONNULL_END
