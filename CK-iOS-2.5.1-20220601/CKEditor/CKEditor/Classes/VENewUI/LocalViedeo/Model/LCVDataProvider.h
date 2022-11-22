//
//  LCVDataProvider.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/25.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCVDataProvider : NSObject

+ (NSArray *)readAllFilesAtDir:(NSString *)dirPath;

+ (NSArray *)readAllDirAtDir:(NSString *)dirPath;

+ (NSArray *)getAllDrafts;


@end

NS_ASSUME_NONNULL_END
