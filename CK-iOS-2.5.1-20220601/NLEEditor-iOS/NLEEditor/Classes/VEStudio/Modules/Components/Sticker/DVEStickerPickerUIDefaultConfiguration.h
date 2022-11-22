//
//   DVEStickerPickerUIDefaultConfiguration.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface DVEStickerPickerUIDefaultCategoryConfiguration : NSObject <DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVEStickerPickerUIDefaultContentConfiguration : NSObject <DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVEStickerPickerUIDefaultConfiguration : NSObject <DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
