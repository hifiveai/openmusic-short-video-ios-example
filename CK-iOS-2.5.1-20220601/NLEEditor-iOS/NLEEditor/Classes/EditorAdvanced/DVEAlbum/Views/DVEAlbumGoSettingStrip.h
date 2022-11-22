//
//  DVEAlbumGoSettingStrip.h
//  CutSameIF
//
//  Created by bytedance on 2020/9/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumGoSettingStrip : UIView

+ (BOOL)closedByUser;
+ (void)setClosedByUser;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *closeButton;

@end

NS_ASSUME_NONNULL_END
