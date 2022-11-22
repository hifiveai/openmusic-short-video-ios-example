//
//  VELogger.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/24.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NLEEditor/DVELoggerProtocol.h>
#import <NLEPlatform/NLELogger_OC.h>
NS_ASSUME_NONNULL_BEGIN

@interface VELogger : NSObject<DVELoggerProtocol, NLELoggerDelegate>


@end

NS_ASSUME_NONNULL_END
