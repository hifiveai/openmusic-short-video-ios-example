//
//  VEUIHelper.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#define VEOptionsStringValue(__value__, __placeholder__) (__value__.length > 0 ? __value__ : __placeholder__)

NS_ASSUME_NONNULL_BEGIN
#define VETopMargn ([VEUIHelper shareManager].topBarMargn + 10)
#define VEBottomMargn [VEUIHelper shareManager].bottomBarMargn
#define VETopMargnValue 28.0
#define VEBottomMargnValue 34.0



@interface VEUIHelper : NSObject

@property (nonatomic, assign)  CGFloat topBarMargn;
@property (nonatomic, assign)  CGFloat bottomBarMargn;

+ (instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
