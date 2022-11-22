//
//  NSArray+RGBA.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (RGBA)
// [0,1,1,1]归一化
- (uint32_t)genRGBA;

@end

//FOUNDATION_EXTERN  NSArray * VEConverRGBAArray(uint32_t rgba);

NS_ASSUME_NONNULL_END
