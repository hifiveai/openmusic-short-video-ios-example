//
//  NSString+VEIEPath.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VEIEPath)

// bundleName/folder/module/unit/self
- (NSString *)pathInBundle:(NSString *)bundleName folder:(NSString *)folder module:(NSString *)module unit:(NSString *)unit;
// bundleName/folder/module/unit/self
- (NSString *)pathInBundle:(NSString *)bundleName module:(NSString *)module unit:(NSString *)unit;
// bundleName/folder/module/unit/self
- (NSString *)pathInBundle:(NSString *)bundleName unit:(NSString *)unit;
// bundleName/self
- (NSString *)pathInBundle:(NSString *)bundleName;

+ (NSString *)VEUUIDString;

@end

