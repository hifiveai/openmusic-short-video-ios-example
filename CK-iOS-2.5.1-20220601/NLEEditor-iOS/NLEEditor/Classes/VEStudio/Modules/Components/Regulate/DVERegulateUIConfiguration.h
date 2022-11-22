//
//  DVERegulateUIConfiguration.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/12.
//

#import <Foundation/Foundation.h>
#import "DVEPickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVERegulateCategoryUIConfiguration : NSObject<DVEPickerCategoryUIConfigurationProtocol>

@end

@interface DVERegulatePickerUIConfiguration : NSObject<DVEPickerEffectUIConfigurationProtocol>

@end

@interface DVERegulateUIConfiguration : NSObject<DVEPickerUIConfigurationProtocol>

@end

NS_ASSUME_NONNULL_END
