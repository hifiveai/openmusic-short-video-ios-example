//
//   DVEFilterPickerUIDefaultConfiguration.h
//   NLEEditor
//
//   Created  by bytedance on 2021/5/8.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    
 
#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEFilterPickerUIDefaultConfiguration : NSObject <DVEPickerUIConfigurationProtocol>

@end


@interface DVEFilterPickerUIDefaultCategoryConfiguration : NSObject <DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVEFilterPickerUIDefaultContentConfiguration : NSObject <DVEPickerEffectUIConfigurationProtocol>

@end




NS_ASSUME_NONNULL_END
