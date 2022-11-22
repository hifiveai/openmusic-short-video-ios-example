//
//  NSString+DVE.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (DVE)

- (NSDictionary *)dve_ToDic;
- (NSArray *)dve_ToArr;
/// 返回路径的名称
- (NSString *)dve_pathName;
/// 返回路径的小写名称
- (NSString *)dve_lowercasePathName;
@end

NS_ASSUME_NONNULL_END
