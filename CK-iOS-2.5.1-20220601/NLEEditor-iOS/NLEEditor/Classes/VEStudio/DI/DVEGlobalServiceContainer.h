//
//  DVEGlobalServiceContainer.h
//  NLEEditor
//
//  Created by bytedance on 2021/9/9.
//

#import <Foundation/Foundation.h>
#import <DVEInject/DVEInject.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEGlobalServiceContainer : DVEContainer

+ (instancetype)sharedContainer;

@end

NS_ASSUME_NONNULL_END
