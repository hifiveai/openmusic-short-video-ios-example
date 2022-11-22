//
//  VECPBaseBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECapBaseView.h"
#import "VECapProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VECPBaseBar : VECapBaseView

@property (nonatomic, weak) id<VECapProtocol> capManager;

@end

NS_ASSUME_NONNULL_END
