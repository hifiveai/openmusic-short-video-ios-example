//
//  DVEVideoToolBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseBar.h"
#import "DVEFullScreenProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEVideoToolBar : DVEBaseBar

@property (nonatomic, weak) id<DVEFullScreenProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
