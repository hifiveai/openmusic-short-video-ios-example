//
//  NSString+VEToPinYin.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (VEToPinYin)

- (NSString *)VE_transformToPinyin;
+ (NSString *)VETimeFormatWithTimeInterval:(NSTimeInterval)duration;
+ (NSString *)curDateString;

@end

NS_ASSUME_NONNULL_END
