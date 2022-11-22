//
//  VEDVideoTool.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/3/9.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEDVideoTool : NSObject

+ (NSTimeInterval)getVideoDurationWithVideoURL:(NSURL *)URL;
+ (CGSize)getVideoSizeWithVideoURL:(NSURL *)URL;
+ (NSString *)deviceVersion;

@end

NS_ASSUME_NONNULL_END
