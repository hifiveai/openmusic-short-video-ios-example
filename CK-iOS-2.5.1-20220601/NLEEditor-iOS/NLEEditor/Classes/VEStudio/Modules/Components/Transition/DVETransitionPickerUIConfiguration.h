//
//   DVETransitionUIConfiguration.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/25.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVETransitionPickerUIDefaultCategoryConfiguration : NSObject <DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVETransitionPickerUIDefaultContentConfiguration : NSObject <DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVETransitionPickerUIDefaultConfiguration : NSObject <DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
