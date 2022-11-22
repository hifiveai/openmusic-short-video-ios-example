//
//  VERouteHelper.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString *const kVECaptureEditViewController;
FOUNDATION_EXTERN NSString *const kVEVideoEditViewController;

@interface VERouteHelper : NSObject

+ (void)routeForVCWithName:(NSString *)vcName;

@end

NS_ASSUME_NONNULL_END
