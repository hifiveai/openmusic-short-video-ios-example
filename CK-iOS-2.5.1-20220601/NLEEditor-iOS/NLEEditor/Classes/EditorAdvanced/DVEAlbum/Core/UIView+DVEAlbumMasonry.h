//
//  UIView+ACCMasonry.h
//  CutSameIF
//
//  Created by bytedance on 2020/8/25.
//

#import <UIKit/UIKit.h>

#define DVEAlbumMasMaker(view, constraints) {\
    MASConstraintMaker *make = [view acc_makeConstraint];\
    if (make) {\
        constraints\
        [make install];\
    }\
}

#define DVEAlbumMasUpdate(view, constraints) {\
    MASConstraintMaker *make = [view acc_updateConstraint];\
    if (make) {\
        constraints\
        [make install];\
    }\
}

#define DVEAlbumMasReMaker(view, constraints) {\
    MASConstraintMaker *make = [view acc_remakeConstraint];\
    if (make) {\
        constraints\
        [make install];\
    }\
}

NS_ASSUME_NONNULL_BEGIN

@class MASConstraintMaker;

@interface UIView (DVEAlbumMasonry)

- (MASConstraintMaker *)acc_makeConstraint;

- (MASConstraintMaker *)acc_updateConstraint;

- (MASConstraintMaker *)acc_remakeConstraint;

@end

NS_ASSUME_NONNULL_END
