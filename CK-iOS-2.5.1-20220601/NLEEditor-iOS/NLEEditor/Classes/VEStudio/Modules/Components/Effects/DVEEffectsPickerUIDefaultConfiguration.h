//
//   DVEEffectsPickerUIDefaultConfiguration.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/12.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface DVEEffectsPickerUIDefaultCategoryConfiguration : NSObject <DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVEEffectsPickerUIDefaultContentConfiguration : NSObject <DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVEEffectsPickerUIDefaultConfiguration : NSObject <DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
