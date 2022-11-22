//
//  DVEResourceCurveSpeedModelProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/6/28.
//

#import <Foundation/Foundation.h>
#import "DVEResourceModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVEResourceCurveSpeedModelProtocol <DVEResourceModelProtocol>

@property (nonatomic, strong) NSArray  *speedPoints;

@end

NS_ASSUME_NONNULL_END
