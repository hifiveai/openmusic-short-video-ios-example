//
//   DVEAnimationPickerUIDefaultConfiguration.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/12.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface DVEAnimationPickerUIDefaultCategoryConfiguration : NSObject <DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVEAnimationPickerUIDefaultContentConfiguration : NSObject <DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVEAnimationPickerUIDefaultConfiguration : NSObject <DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
