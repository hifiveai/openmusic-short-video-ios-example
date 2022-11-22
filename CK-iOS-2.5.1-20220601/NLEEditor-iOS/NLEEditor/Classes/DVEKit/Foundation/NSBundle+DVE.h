//
//  NSBundle+DVE.h
//  NLEEditor-iOS
//
//  Created by bytedance on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (DVE)

+ (nullable NSBundle *)dve_bundleWithName:(NSString *)name;

+ (NSBundle *)dve_mainBundle;

@end

NS_ASSUME_NONNULL_END
