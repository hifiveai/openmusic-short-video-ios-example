//
//  DVECanvasUIConfiguration.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/1.
//

#import <Foundation/Foundation.h>
#import "DVEPickerUIConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVECanvasColorCategoryUIConfiguration : NSObject<DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVECanvasColorItemUIConfiguration : NSObject<DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVECanvasColorUIConfiguration : NSObject<DVEPickerUIConfigurationProtocol>

@end


@interface DVECanvasStyleCategoryUIConfiguration : NSObject<DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVECanvasStyleItemUIConfiguration : NSObject<DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVECanvasStyleUIConfiguration : NSObject<DVEPickerUIConfigurationProtocol>

@end

@interface DVECanvasBlurCategoryUIConfiguration : NSObject<DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVECanvasBlurItemUIConfiguration : NSObject<DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVECanvasBlurUIConfiguration : NSObject<DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
