//
//  DVEToast.h
//  IESVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2019 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEToast : NSObject

+ (void)showInfo:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
