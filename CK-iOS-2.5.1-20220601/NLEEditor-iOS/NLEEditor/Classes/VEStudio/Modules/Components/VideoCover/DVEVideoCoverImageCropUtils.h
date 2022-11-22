//
//  DVEVideoCoverImageCropUtils.h
//  NLEEditor
//
//  Created by pengzhenhuan on 2021/11/1.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN CGSize DVE_limitMaxSize(CGSize size, CGSize maxSize);
FOUNDATION_EXTERN CGSize DVE_aspectFitMaxSize(CGSize size, CGSize maxSize);
FOUNDATION_EXTERN CGSize DVE_aspectFitMinSize(CGSize size, CGSize minSize);
FOUNDATION_EXTERN CGRect DVE_fixCropRectForImage(CGRect rect, UIImage *image);
FOUNDATION_EXTERN NSArray<NSValue *> * DVE_defaultCropForImage(CGSize imageSize, CGSize canvasSize);


