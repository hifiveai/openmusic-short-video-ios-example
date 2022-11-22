//
//  DVEBundleDataSource.h
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import <Foundation/Foundation.h>
#import <NLEPlatform/NLEBundleDataSource.h>
#import "DVEVCContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEBundleDataSource : NSObject<NLEBundleDataSource>

- (instancetype)initWithVEVCContext:(DVEVCContext *)vcContext;

@end

NS_ASSUME_NONNULL_END
