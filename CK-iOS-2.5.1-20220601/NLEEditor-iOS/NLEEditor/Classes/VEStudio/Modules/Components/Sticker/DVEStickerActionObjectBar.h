//
//  DVEStickerActionObjectBar.h
//  NLEEditor
//
//  Created by bytedance on 2021/8/10.
//

#import "DVEBaseBar.h"
#import <NLEPlatform/NLEStyStickerAnimation+iOS.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEStickerActionObjectBarDelegate <NSObject>

- (void)animationDidUpdate;

@end

@interface DVEStickerActionObjectBar : DVEBaseBar

@property (nonatomic, strong) id<DVEStickerActionObjectBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
